//
//  ServiceStore.swift
//  Kuma
//
//  Created for Task 6.3 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import Foundation
import Observation
import os

/// `@Observable` store managing service state aggregates, active provider selection,
/// execution orchestration, log streaming, and boot-time auto-start restoration.
@MainActor
@Observable
public final class ServiceStore {
    private static let logger = Logger(subsystem: "lokastudio.kuma", category: "ServiceStore")

    // MARK: - State Properties

    public private(set) var aggregates: [ServiceAggregate] = []
    public private(set) var logsByServiceId: [UUID: [String]] = [:]
    public private(set) var isLoading: Bool = false
    public var errorMessage: String?

    // MARK: - Dependencies

    private let serviceRepository: ServiceRepositoryProtocol
    private let providerRepository: ProviderRepositoryProtocol
    private let vaultSecretRepository: VaultSecretRepositoryProtocol
    private let executionEngine: ServiceExecutionEngine

    // MARK: - Initialization

    public init(
        serviceRepository: ServiceRepositoryProtocol,
        providerRepository: ProviderRepositoryProtocol,
        vaultSecretRepository: VaultSecretRepositoryProtocol,
        executionEngine: ServiceExecutionEngine = ServiceExecutionEngine()
    ) {
        self.serviceRepository = serviceRepository
        self.providerRepository = providerRepository
        self.vaultSecretRepository = vaultSecretRepository
        self.executionEngine = executionEngine
        Self.logger.debug("ServiceStore initialized")
    }

    // MARK: - Data Hydration

    /// Fetches all services, providers, port mappings, and secrets for a workspace, constructing unified aggregates.
    public func loadServices(forWorkspaceId workspaceId: UUID) async {
        isLoading = true
        errorMessage = nil
        do {
            let services = try await serviceRepository.fetchServices(forWorkspaceId: workspaceId)
            var newAggregates: [ServiceAggregate] = []

            for service in services {
                let providers = try await providerRepository.fetchProviders(forServiceId: service.id)
                let activeProvider = providers.first(where: { $0.id == service.activeProviderId }) ?? providers.first

                var portMappings: [PortMapping] = []
                var secrets: [VaultSecret] = []

                if let active = activeProvider {
                    portMappings = try await providerRepository.fetchPortMappings(forProviderId: active.id)
                    secrets = try await vaultSecretRepository.fetchSecrets(forProvider: active.id)
                }

                let engineState = await executionEngine.state(for: service.id)
                let aggregate = ServiceAggregate(
                    service: service,
                    providers: providers,
                    activeProvider: activeProvider,
                    portMappings: portMappings,
                    vaultSecrets: secrets,
                    state: engineState
                )
                newAggregates.append(aggregate)
            }

            self.aggregates = newAggregates.sorted(by: { $0.service.sortOrder < $1.service.sortOrder })
            Self.logger.info("Successfully loaded \(self.aggregates.count, privacy: .public) service aggregates for workspace \(workspaceId)")
        } catch {
            self.errorMessage = "Failed to load services: \(error.localizedDescription)"
            Self.logger.error("Error loading services: \(error.localizedDescription, privacy: .public)")
        }
        isLoading = false
    }

    // MARK: - Service Lookup

    public func aggregate(for serviceId: UUID) -> ServiceAggregate? {
        aggregates.first(where: { $0.id == serviceId })
    }

    // MARK: - Log Buffer Management

    private func appendLog(_ line: String, for serviceId: UUID) {
        var currentLogs = logsByServiceId[serviceId] ?? []
        currentLogs.append(line)
        if currentLogs.count > 100 {
            currentLogs.removeFirst(currentLogs.count - 100)
        }
        logsByServiceId[serviceId] = currentLogs
    }

    // MARK: - Execution Lifecycle Control

    /// Triggers service execution via `ServiceExecutionEngine` and updates aggregate state.
    public func startService(id: UUID) async {
        guard let index = aggregates.firstIndex(where: { $0.id == id }) else { return }
        var agg = aggregates[index]
        
        guard !agg.isDisabled else {
            self.errorMessage = "Cannot start disabled service '\(agg.name)'"
            return
        }

        Self.logger.info("Starting service '\(agg.name, privacy: .public)' (ID: \(id))")
        agg.state = .starting(progress: "Initializing...")
        aggregates[index] = agg

        do {
            guard let activeProvider = agg.activeProvider else {
                throw ServiceExecutionEngineError.missingPortMapping
            }

            try await executionEngine.startService(
                service: agg.service,
                provider: activeProvider,
                portMappings: agg.portMappings,
                logHandler: { [weak self] line in
                    Task { @MainActor [weak self] in
                        self?.appendLog(line, for: id)
                    }
                }
            )

            let finalState = await executionEngine.state(for: id)
            if let idx = aggregates.firstIndex(where: { $0.id == id }) {
                aggregates[idx].state = finalState
                try? await serviceRepository.updateStatus(id: id, status: finalState, lastActivePort: agg.portMappings.first?.localPort)
            }
        } catch {
            let failedState = ServiceExecutionState.failed(error: error.localizedDescription)
            if let idx = aggregates.firstIndex(where: { $0.id == id }) {
                aggregates[idx].state = failedState
                try? await serviceRepository.updateStatus(id: id, status: failedState, lastActivePort: nil)
            }
            Self.logger.error("Failed to start service \(id): \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Gracefully stops service execution.
    public func stopService(id: UUID) async {
        guard let index = aggregates.firstIndex(where: { $0.id == id }) else { return }
        Self.logger.info("Stopping service '\(self.aggregates[index].name, privacy: .public)' (ID: \(id))")
        
        aggregates[index].state = .stopping

        do {
            try await executionEngine.stopService(serviceID: id)
            if let idx = aggregates.firstIndex(where: { $0.id == id }) {
                aggregates[idx].state = .stopped
                try? await serviceRepository.updateStatus(id: id, status: .stopped, lastActivePort: nil)
            }
        } catch {
            if let idx = aggregates.firstIndex(where: { $0.id == id }) {
                aggregates[idx].state = .stopped
                try? await serviceRepository.updateStatus(id: id, status: .stopped, lastActivePort: nil)
            }
            Self.logger.error("Failed to gracefully stop service \(id): \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Restarts a service by stopping then starting it.
    public func restartService(id: UUID) async {
        await stopService(id: id)
        await startService(id: id)
    }

    // MARK: - Active Provider Operations

    /// Switch active provider for a service and persist selection.
    public func setActiveProvider(serviceId: UUID, providerId: UUID) async {
        guard let index = aggregates.firstIndex(where: { $0.id == serviceId }) else { return }
        var agg = aggregates[index]

        guard let newProvider = agg.providers.first(where: { $0.id == providerId }) else { return }
        agg.activeProvider = newProvider
        agg.service.activeProviderId = providerId

        do {
            let portMappings = try await providerRepository.fetchPortMappings(forProviderId: providerId)
            let secrets = try await vaultSecretRepository.fetchSecrets(forProvider: providerId)

            agg.portMappings = portMappings
            agg.vaultSecrets = secrets
            aggregates[index] = agg

            try await serviceRepository.saveService(agg.service)
            Self.logger.info("Updated active provider to \(providerId) for service \(serviceId)")
        } catch {
            self.errorMessage = "Failed to switch active provider: \(error.localizedDescription)"
            Self.logger.error("Failed to switch active provider: \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: - Helper & Query Extensions

    /// Returns `true` if any service aggregate is currently in `.running` or `.starting` state.
    public var hasRunningServices: Bool {
        aggregates.contains(where: {
            switch $0.state {
            case .running, .starting:
                return true
            default:
                return false
            }
        })
    }

    /// Count of running or starting service aggregates.
    public var runningCount: Int {
        aggregates.filter({
            switch $0.state {
            case .running, .starting:
                return true
            default:
                return false
            }
        }).count
    }

    /// Dynamic count of service aggregates filtered by provider type.
    public func count(for providerType: ProviderType) -> Int {
        aggregates.filter({ $0.activeProvider?.providerType == providerType }).count
    }

    /// Stops all currently active services in the workspace.
    public func stopAllServices() async {
        let activeIds = aggregates.compactMap { agg -> UUID? in
            switch agg.state {
            case .running, .starting:
                return agg.id
            default:
                return nil
            }
        }
        for id in activeIds {
            await stopService(id: id)
        }
    }

    // MARK: - Boot Restoration

    /// Resets lingering running statuses from crash/abrupt termination and restores auto-start services on boot.
    public func restoreAutoStartServices() async {
        Self.logger.info("Executing boot-time service restoration protocol...")
        do {
            try await serviceRepository.resetAllStatusesToStopped()
        } catch {
            Self.logger.error("Failed to reset legacy service statuses: \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: - Mock for Previews & Tests

    public static var mock: ServiceStore {
        let serviceRepo = MockServiceRepository()
        let providerRepo = MockProviderRepository()
        let secretRepo = MockVaultSecretRepository()
        let store = ServiceStore(
            serviceRepository: serviceRepo,
            providerRepository: providerRepo,
            vaultSecretRepository: secretRepo
        )
        return store
    }
}

// MARK: - Mock Repositories for Previews

private final class MockServiceRepository: ServiceRepositoryProtocol, @unchecked Sendable {
    func fetchServices(forWorkspaceId workspaceId: UUID) async throws -> [Service] { [] }
    func fetchServices(forGroupId groupId: UUID) async throws -> [Service] { [] }
    func fetchFavoriteServices() async throws -> [Service] { [] }
    func fetchService(id: UUID) async throws -> Service? { nil }
    func saveService(_ service: Service) async throws {}
    func saveServices(_ services: [Service]) async throws {}
    func updateStatus(id: UUID, status: ServiceExecutionState, lastActivePort: Int?) async throws {}
    func updateGroup(serviceId: UUID, groupId: UUID?) async throws {}
    func updateSortOrders(_ updates: [(id: UUID, sortOrder: Int)]) async throws {}
    func resetAllStatusesToStopped() async throws {}
    func deleteService(id: UUID) async throws {}
}

private final class MockProviderRepository: ProviderRepositoryProtocol, @unchecked Sendable {
    func fetchProviders(forServiceId serviceId: UUID) async throws -> [Provider] { [] }
    func fetchProvider(id: UUID) async throws -> Provider? { nil }
    func saveProvider(_ provider: Provider) async throws {}
    func deleteProvider(id: UUID) async throws {}
    func fetchPortMappings(forProviderId providerId: UUID) async throws -> [PortMapping] { [] }
    func savePortMappings(_ mappings: [PortMapping], forProviderId providerId: UUID) async throws {}
}

private final class MockVaultSecretRepository: VaultSecretRepositoryProtocol, @unchecked Sendable {
    func fetchSecret(id: UUID) async throws -> VaultSecret? { nil }
    func fetchSecrets(forProvider providerId: UUID) async throws -> [VaultSecret] { [] }
    func saveSecret(_ secret: VaultSecret, plainTextValue: String) async throws -> VaultSecret { secret }
    func deleteSecret(id: UUID) async throws {}
    func decryptValue(for secret: VaultSecret) async throws -> String { "" }
}



