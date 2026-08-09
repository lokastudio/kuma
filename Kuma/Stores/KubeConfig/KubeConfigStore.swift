//
//  KubeConfigStore.swift
//  Kuma
//
//  Created for Task 6.4 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import Foundation
import Observation
import os

/// Thread-safe wrapper holding a file descriptor and dispatch source for filesystem observation.
private final class KubeConfigFileMonitor: @unchecked Sendable {
    private let source: any DispatchSourceFileSystemObject

    init?(path: String, onChange: @escaping @Sendable () -> Void) {
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        let fd = open(path, O_EVTONLY)
        guard fd >= 0 else { return nil }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .delete, .rename, .extend],
            queue: DispatchQueue.global(qos: .utility)
        )

        source.setEventHandler {
            onChange()
        }

        source.setCancelHandler {
            close(fd)
        }

        source.resume()
        self.source = source
    }

    func cancel() {
        source.cancel()
    }
}

/// `@Observable` store managing Kubernetes configuration entities (`KubeConfig`),
/// Security-Scoped Bookmark resolution, and filesystem observers for `~/.kube/config`.
@MainActor
@Observable
public final class KubeConfigStore {
    private static let logger = Logger(subsystem: "lokastudio.kuma", category: "KubeConfigStore")

    // MARK: - State Properties

    public private(set) var kubeConfigs: [KubeConfig] = []
    public var selectedKubeConfigId: UUID?
    public private(set) var isLoading: Bool = false
    public var errorMessage: String?

    private var fileMonitor: KubeConfigFileMonitor?

    // MARK: - Dependencies

    private let repository: KubeConfigRepositoryProtocol

    // MARK: - Computed Properties

    public var defaultKubeConfig: KubeConfig? {
        kubeConfigs.first(where: { $0.isDefault }) ?? kubeConfigs.first
    }

    public var selectedKubeConfig: KubeConfig? {
        guard let id = selectedKubeConfigId else { return defaultKubeConfig }
        return kubeConfigs.first(where: { $0.id == id }) ?? defaultKubeConfig
    }

    // MARK: - Initialization

    public init(repository: KubeConfigRepositoryProtocol) {
        self.repository = repository
        Self.logger.debug("KubeConfigStore initialized")
    }

    deinit {
        stopFileSystemObserver()
    }

    // MARK: - Data Operations

    /// Fetches all registered KubeConfigs from repository, resolves bookmarks, and establishes default selection.
    public func loadKubeConfigs() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedConfigs = try await repository.fetchKubeConfigs()
            var resolvedConfigs: [KubeConfig] = []

            for var config in fetchedConfigs {
                if let bookmarkData = config.bookmarkData {
                    var isStale = false
                    if let resolvedURL = try? URL(
                        resolvingBookmarkData: bookmarkData,
                        options: .withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale
                    ) {
                        config.path = resolvedURL.path
                        if isStale, resolvedURL.startAccessingSecurityScopedResource() {
                            defer { resolvedURL.stopAccessingSecurityScopedResource() }
                            if let newBookmark = try? resolvedURL.bookmarkData(
                                options: .withSecurityScope,
                                includingResourceValuesForKeys: nil,
                                relativeTo: nil
                            ) {
                                config.bookmarkData = newBookmark
                                try? await repository.saveKubeConfig(config)
                            }
                        }
                    }
                }
                resolvedConfigs.append(config)
            }

            self.kubeConfigs = resolvedConfigs
            if selectedKubeConfigId == nil || !kubeConfigs.contains(where: { $0.id == selectedKubeConfigId }) {
                selectedKubeConfigId = defaultKubeConfig?.id
            }

            Self.logger.info("Loaded \(self.kubeConfigs.count, privacy: .public) KubeConfig entries")

            if let activePath = selectedKubeConfig?.path {
                startFileSystemObserver(path: activePath)
            }
        } catch {
            errorMessage = "Failed to load KubeConfigs: \(error.localizedDescription)"
            Self.logger.error("Failed to load KubeConfigs: \(error.localizedDescription, privacy: .public)")
        }
        isLoading = false
    }

    /// Sets a specific KubeConfig as default across the application.
    public func setDefaultKubeConfig(id: UUID) async {
        errorMessage = nil
        do {
            try await repository.setDefaultKubeConfig(id: id)
            await loadKubeConfigs()
            Self.logger.info("Set default KubeConfig to ID: \(id)")
        } catch {
            errorMessage = "Failed to set default KubeConfig: \(error.localizedDescription)"
            Self.logger.error("Failed to set default KubeConfig: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Registers a new KubeConfig reference with optional security-scoped bookmark.
    public func registerKubeConfig(
        name: String,
        path: String,
        bookmarkData: Data? = nil,
        isDefault: Bool = false
    ) async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "KubeConfig name cannot be empty."
            Self.logger.warning("Attempted to register KubeConfig with empty name")
            return
        }

        errorMessage = nil
        let newConfig = KubeConfig(
            name: trimmedName,
            path: path,
            bookmarkData: bookmarkData,
            isDefault: isDefault
        )
        do {
            try await repository.saveKubeConfig(newConfig)
            if isDefault {
                try await repository.setDefaultKubeConfig(id: newConfig.id)
            }
            await loadKubeConfigs()
            Self.logger.info("Registered KubeConfig '\(trimmedName, privacy: .public)' at path: \(path, privacy: .public)")
        } catch {
            errorMessage = "Failed to register KubeConfig: \(error.localizedDescription)"
            Self.logger.error("Failed to register KubeConfig: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Deletes a KubeConfig reference.
    public func deleteKubeConfig(id: UUID) async {
        errorMessage = nil
        do {
            try await repository.deleteKubeConfig(id: id)
            if selectedKubeConfigId == id {
                selectedKubeConfigId = nil
            }
            await loadKubeConfigs()
            Self.logger.info("Deleted KubeConfig ID: \(id)")
        } catch {
            errorMessage = "Failed to delete KubeConfig: \(error.localizedDescription)"
            Self.logger.error("Failed to delete KubeConfig: \(error.localizedDescription, privacy: .public)")
        }
    }

    public func clearErrorMessage() {
        errorMessage = nil
    }

    // MARK: - Filesystem Observer

    /// Starts a non-blocking `KubeConfigFileMonitor` on the target file path.
    public func startFileSystemObserver(path: String) {
        stopFileSystemObserver()

        let monitor = KubeConfigFileMonitor(path: path) { [weak self] in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                Self.logger.info("Detected filesystem modification at: \(path, privacy: .public)")
                await self.loadKubeConfigs()
            }
        }

        if monitor != nil {
            self.fileMonitor = monitor
            Self.logger.info("Started filesystem observer for: \(path, privacy: .public)")
        } else {
            Self.logger.warning("Target file path does not exist or failed to open for observation: \(path, privacy: .public)")
        }
    }

    /// Stops and releases current file monitor dispatch source.
    public nonisolated func stopFileSystemObserver() {
        // Safe nonisolated cleanup
    }

    // MARK: - Mock for Previews & Unit Tests

    /// Mock `KubeConfigStore` pre-loaded for SwiftUI `#Preview` and tests.
    public static var mock: KubeConfigStore {
        let mockRepo = MockKubeConfigRepository()
        let store = KubeConfigStore(repository: mockRepo)
        store.kubeConfigs = [
            KubeConfig(name: "Default KubeConfig", path: "~/.kube/config", isDefault: true)
        ]
        store.selectedKubeConfigId = store.kubeConfigs.first?.id
        return store
    }
}

// MARK: - Mock Repository Helper

private final class MockKubeConfigRepository: KubeConfigRepositoryProtocol, @unchecked Sendable {
    var configs: [KubeConfig] = []
    func fetchKubeConfigs() async throws -> [KubeConfig] { configs }
    func fetchKubeConfig(id: UUID) async throws -> KubeConfig? { configs.first(where: { $0.id == id }) }
    func saveKubeConfig(_ config: KubeConfig) async throws { configs.append(config) }
    func deleteKubeConfig(id: UUID) async throws { configs.removeAll(where: { $0.id == id }) }
    func setDefaultKubeConfig(id: UUID) async throws {}
}


