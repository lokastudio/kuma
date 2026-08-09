//
//  ServiceExecutionEngine.swift
//  Kuma
//
//  Created by Antigravity on 2026-08-09.
//

import Foundation
import os

/// Errors encountered during service execution orchestration.
public enum ServiceExecutionEngineError: Error, Sendable, LocalizedError, Equatable {
    case serviceDisabled(UUID)
    case invalidExecutable(String)
    case missingPortMapping
    case processAlreadyRunning(UUID)
    case executionFailed(String)
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .serviceDisabled(let id):
            return "Service '\(id)' is currently disabled and cannot be started."
        case .invalidExecutable(let path):
            return "Invalid executable or binary path: '\(path)'."
        case .missingPortMapping:
            return "No valid port mapping provided for execution."
        case .processAlreadyRunning(let id):
            return "Execution task for service '\(id)' is already active."
        case .executionFailed(let reason):
            return "Service execution failed: \(reason)"
        case .cancelled:
            return "Service execution task was cancelled."
        }
    }
}

/// Core execution orchestrator actor managing service state transitions, subprocess lifecycles,
/// background monitoring tasks, and log streaming.
public actor ServiceExecutionEngine {
    private let logger = Logger(subsystem: "com.kuma.app", category: "ProcessEngine")
    
    private let pathResolver: EnvironmentPathResolver
    private let processRunner: ProcessRunner
    private let processRegistry: ProcessRegistry
    
    /// Track active execution monitoring tasks per service ID.
    private var activeTasks: [UUID: Task<Void, Never>] = [:]
    
    /// Track current execution state per service ID.
    private var states: [UUID: ServiceExecutionState] = [:]

    public init(
        pathResolver: EnvironmentPathResolver = EnvironmentPathResolver.shared,
        processRunner: ProcessRunner? = nil,
        processRegistry: ProcessRegistry = ProcessRegistry.shared
    ) {
        self.pathResolver = pathResolver
        self.processRegistry = processRegistry
        self.processRunner = processRunner ?? ProcessRunner(registry: processRegistry)
    }

    // MARK: - State Inspection

    /// Retrieves current execution state for a service.
    public func state(for serviceId: UUID) -> ServiceExecutionState {
        states[serviceId] ?? .stopped
    }

    /// Checks whether a service task is currently active.
    public func isServiceActive(serviceId: UUID) -> Bool {
        activeTasks[serviceId] != nil
    }

    // MARK: - Execution Management

    /// Starts a service process using the specified provider configuration and port mappings.
    ///
    /// - Parameters:
    ///   - service: The domain `Service` to execute.
    ///   - provider: The target `Provider` configuration.
    ///   - portMappings: Associated `PortMapping` list.
    ///   - logHandler: Optional async handler for consuming streamed logs.
    /// - Returns: Updated `ServiceExecutionState`.
    @discardableResult
    public func startService(
        service: Service,
        provider: Provider,
        portMappings: [PortMapping] = [],
        logHandler: (@Sendable (String) -> Void)? = nil
    ) async throws -> ServiceExecutionState {
        guard !service.isDisabled else {
            logger.warning("Attempted to start disabled service: \(service.id, privacy: .public)")
            throw ServiceExecutionEngineError.serviceDisabled(service.id)
        }

        if activeTasks[service.id] != nil {
            logger.warning("Service \(service.id, privacy: .public) is already running or starting.")
            throw ServiceExecutionEngineError.processAlreadyRunning(service.id)
        }

        // Apply startup jittering (0-1200ms) to prevent thundering herd during bulk launches
        let jitterMs = UInt64.random(in: 0...1200)
        try await Task.sleep(nanoseconds: jitterMs * 1_000_000)
        
        if Task.isCancelled {
            throw ServiceExecutionEngineError.cancelled
        }

        updateState(for: service.id, to: .starting(progress: "Preparing binary PATH..."))

        // Build execution parameters depending on provider type
        let executionConfig: ProcessExecutionConfig
        let primaryPort = portMappings.first?.localPort ?? service.lastActivePort ?? 0

        do {
            executionConfig = try await buildConfig(
                service: service,
                provider: provider,
                portMappings: portMappings
            )
        } catch {
            let failureState = ServiceExecutionState.failed(error: error.localizedDescription)
            updateState(for: service.id, to: failureState)
            throw error
        }

        updateState(for: service.id, to: .starting(progress: "Spawning subprocess..."))

        // Spawn process stream
        let (stream, executionTask) = await processRunner.stream(config: executionConfig)
        
        // Spawn background task to monitor stream output & completion
        let serviceId = service.id
        let monitoringTask = Task { [weak self] in
            // Handle output streaming
            for await line in stream {
                if Task.isCancelled { break }
                logHandler?(line)
            }
            
            // Await execution exit status
            let result = await executionTask.result
            guard let self = self else { return }
            
            await self.handleTaskCompletion(
                serviceId: serviceId,
                result: result,
                primaryPort: primaryPort
            )
        }

        activeTasks[service.id] = monitoringTask

        // Brief delay to check early crash vs. successful startup
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        let currentState = states[service.id] ?? .stopped
        if case .failed(let err) = currentState {
            throw ServiceExecutionEngineError.executionFailed(err)
        }

        // Update state to running if not marked failed or stopping
        if case .starting = currentState {
            let activeHandles = await processRegistry.activeProcesses(forService: service.id)
            let actualPid = activeHandles.first?.pid ?? 0
            let runningState = ServiceExecutionState.running(pid: actualPid, activePort: primaryPort)
            updateState(for: service.id, to: runningState)
        }

        return states[service.id] ?? .stopped
    }

    /// Gracefully terminates a running service process via `ProcessRegistry`.
    public func stopService(serviceID: UUID) async throws {
        guard let task = activeTasks[serviceID] else {
            updateState(for: serviceID, to: .stopped)
            return
        }

        updateState(for: serviceID, to: .stopping)

        // Cancel background stream monitoring task
        task.cancel()
        activeTasks.removeValue(forKey: serviceID)

        // Terminate process tree via registry for target service ID
        let handles = await processRegistry.activeProcesses(forService: serviceID)
        for handle in handles {
            await processRegistry.terminateProcessGroup(pgid: handle.pgid)
        }

        updateState(for: serviceID, to: .stopped)
        logger.info("Service \(serviceID, privacy: .public) stopped cleanly.")
    }

    /// Restarts a service by stopping any existing process and re-launching it.
    @discardableResult
    public func restartService(
        service: Service,
        provider: Provider,
        portMappings: [PortMapping] = [],
        logHandler: (@Sendable (String) -> Void)? = nil
    ) async throws -> ServiceExecutionState {
        try await stopService(serviceID: service.id)
        return try await startService(
            service: service,
            provider: provider,
            portMappings: portMappings,
            logHandler: logHandler
        )
    }

    // MARK: - Private Helpers

    private func updateState(for serviceId: UUID, to newState: ServiceExecutionState) {
        states[serviceId] = newState
        logger.info("Service \(serviceId, privacy: .public) state changed -> \(newState.dbStatusString, privacy: .public)")
    }

    private func handleTaskCompletion(
        serviceId: UUID,
        result: Result<ProcessExecutionResult, Error>,
        primaryPort: Int
    ) async {
        activeTasks.removeValue(forKey: serviceId)

        switch result {
        case .success(let executionResult):
            if executionResult.exitCode == 0 || executionResult.exitCode == 130 || executionResult.exitCode == 143 { // 130 SIGINT, 143 SIGTERM
                updateState(for: serviceId, to: .stopped)
            } else {
                let err = executionResult.stderr.isEmpty ? "Exited with code \(executionResult.exitCode)" : executionResult.stderr
                updateState(for: serviceId, to: .failed(error: err))
            }
        case .failure(let error):
            if error is CancellationError || (error as? ProcessRunnerError) == .cancelled {
                updateState(for: serviceId, to: .stopped)
            } else {
                updateState(for: serviceId, to: .failed(error: error.localizedDescription))
            }
        }
    }

    private func buildConfig(
        service: Service,
        provider: Provider,
        portMappings: [PortMapping]
    ) async throws -> ProcessExecutionConfig {
        switch provider.config {
        case .shellScript(let payload):
            let shellPath = try await pathResolver.resolveExecutablePath(for: "zsh") ?? "/bin/zsh"
            let workDirURL = payload.workingDirectory != nil ? URL(fileURLWithPath: payload.workingDirectory!) : nil
            return ProcessExecutionConfig(
                executableURL: URL(fileURLWithPath: shellPath),
                arguments: ["-c", payload.command],
                environment: payload.environmentVariables,
                currentDirectoryURL: workDirURL,
                serviceId: service.id,
                providerId: provider.id
            )

        case .kubePortForward(let payload):
            let kubectlPath = try await pathResolver.resolveExecutablePath(for: "kubectl") ?? "/usr/local/bin/kubectl"
            let localPort = portMappings.first?.localPort ?? 8080
            let remotePort = portMappings.first?.remotePort ?? localPort
            
            var args = [
                "--context", payload.context,
                "--namespace", payload.namespace,
                "port-forward",
                "\(payload.resourceType)/\(payload.resourceName)",
                "\(localPort):\(remotePort)"
            ]
            if let kubeConfigId = payload.kubeConfigId {
                args.append(contentsOf: ["--kubeconfig", kubeConfigId.uuidString])
            }

            return ProcessExecutionConfig(
                executableURL: URL(fileURLWithPath: kubectlPath),
                arguments: args,
                serviceId: service.id,
                providerId: provider.id
            )

        case .dockerCompose(let payload):
            let dockerPath = try await pathResolver.resolveExecutablePath(for: "docker") ?? "/usr/local/bin/docker"
            var args = ["compose"]
            if let composeFile = payload.composeFilePath {
                args.append(contentsOf: ["-f", composeFile])
            }
            args.append(contentsOf: ["up", payload.serviceName])

            return ProcessExecutionConfig(
                executableURL: URL(fileURLWithPath: dockerPath),
                arguments: args,
                environment: payload.environmentVariables,
                currentDirectoryURL: URL(fileURLWithPath: payload.projectDirectory),
                serviceId: service.id,
                providerId: provider.id
            )

        case .podmanCompose(let payload):
            let podmanPath = try await pathResolver.resolveExecutablePath(for: "podman-compose") ?? "/usr/local/bin/podman-compose"
            var args: [String] = []
            if let composeFile = payload.composeFilePath {
                args.append(contentsOf: ["-f", composeFile])
            }
            args.append(contentsOf: ["up", payload.serviceName])

            return ProcessExecutionConfig(
                executableURL: URL(fileURLWithPath: podmanPath),
                arguments: args,
                environment: payload.environmentVariables,
                currentDirectoryURL: URL(fileURLWithPath: payload.projectDirectory),
                serviceId: service.id,
                providerId: provider.id
            )

        case .sshTunnel(let payload):
            let sshPath = try await pathResolver.resolveExecutablePath(for: "ssh") ?? "/usr/bin/ssh"
            let localPort = portMappings.first?.localPort ?? 8080
            let remotePort = payload.remotePort
            let tunnelSpec = "\(localPort):\(payload.remoteHost):\(remotePort)"

            var args = [
                "-N",
                "-L", tunnelSpec,
                "-p", "\(payload.port)",
                "\(payload.username)@\(payload.host)"
            ]

            if case .keyFile(let keyPath) = payload.authMethod {
                args.append(contentsOf: ["-i", keyPath])
            }

            return ProcessExecutionConfig(
                executableURL: URL(fileURLWithPath: sshPath),
                arguments: args,
                serviceId: service.id,
                providerId: provider.id
            )

        case .httpCheck(let payload):
            let curlPath = try await pathResolver.resolveExecutablePath(for: "curl") ?? "/usr/bin/curl"
            return ProcessExecutionConfig(
                executableURL: URL(fileURLWithPath: curlPath),
                arguments: ["-i", "-s", payload.url],
                serviceId: service.id,
                providerId: provider.id
            )

        case .tunnel(let payload):
            let binaryName = payload.provider == .cloudflared ? "cloudflared" : "ngrok"
            let tunnelPath = try await pathResolver.resolveExecutablePath(for: binaryName) ?? "/usr/local/bin/\(binaryName)"
            let args = payload.provider == .cloudflared
                ? ["tunnel", "--url", "http://localhost:\(payload.localPort)"]
                : ["http", "\(payload.localPort)"]

            return ProcessExecutionConfig(
                executableURL: URL(fileURLWithPath: tunnelPath),
                arguments: args,
                serviceId: service.id,
                providerId: provider.id
            )

        case .processMonitor(let payload):
            let pgrepPath = try await pathResolver.resolveExecutablePath(for: "pgrep") ?? "/usr/bin/pgrep"
            let procName = payload.processName ?? "system"
            return ProcessExecutionConfig(
                executableURL: URL(fileURLWithPath: pgrepPath),
                arguments: ["-lf", procName],
                serviceId: service.id,
                providerId: provider.id
            )
        }
    }
}
