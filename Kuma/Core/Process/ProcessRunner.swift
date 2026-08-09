//
//  ProcessRunner.swift
//  Kuma
//
//  Created by Antigravity on 2026-08-09.
//

import Foundation
import os

/// Errors encountered during process execution.
public enum ProcessRunnerError: Error, Sendable, LocalizedError, Equatable {
    case executableNotFound(String)
    case launchFailed(String)
    case executionTerminated(exitCode: Int32, stderr: String)
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .executableNotFound(let path):
            return "Executable not found at path: \(path)"
        case .launchFailed(let message):
            return "Failed to launch process: \(message)"
        case .executionTerminated(let exitCode, let stderr):
            return "Process terminated with exit code \(exitCode): \(stderr)"
        case .cancelled:
            return "Process execution was cancelled"
        }
    }
}

/// Configuration options for launching a process.
public struct ProcessExecutionConfig: Sendable {
    public let executableURL: URL
    public let arguments: [String]
    public let environment: [String: String]?
    public let currentDirectoryURL: URL?
    public let serviceId: UUID
    public let providerId: UUID

    public nonisolated init(
        executableURL: URL,
        arguments: [String] = [],
        environment: [String: String]? = nil,
        currentDirectoryURL: URL? = nil,
        serviceId: UUID = UUID(),
        providerId: UUID = UUID()
    ) {
        self.executableURL = executableURL
        self.arguments = arguments
        self.environment = environment
        self.currentDirectoryURL = currentDirectoryURL
        self.serviceId = serviceId
        self.providerId = providerId
    }
}

/// Result payload returned upon completion of a one-shot process run.
public struct ProcessExecutionResult: Sendable, Equatable {
    public let exitCode: Int32
    public let stdout: String
    public let stderr: String
    public let duration: TimeInterval

    public nonisolated init(
        exitCode: Int32,
        stdout: String,
        stderr: String,
        duration: TimeInterval
    ) {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
        self.duration = duration
    }
}

/// Subprocess runner that manages process group isolation (`setpgid`), 
/// pipe handle deferral, output streaming, and `ProcessRegistry` integration.
public actor ProcessRunner {
    private let logger = Logger(subsystem: "com.kuma.app", category: "ProcessEngine")
    private let registry: ProcessRegistry

    public init(registry: ProcessRegistry = .shared) {
        self.registry = registry
    }

    // MARK: - One-Shot Execution

    /// Runs a process to completion, capturing standard output and error.
    public func run(config: ProcessExecutionConfig) async throws -> ProcessExecutionResult {
        let (stream, executionTask) = stream(config: config)
        
        // Consume stream asynchronously to prevent pipe backpressure deadlock
        let stdoutCollectorTask = Task {
            var lines: [String] = []
            for await line in stream {
                lines.append(line)
            }
            return lines.joined(separator: "\n")
        }

        let result = try await executionTask.value
        let collectedStdout = await stdoutCollectorTask.value

        // Reconstruct result with complete captured output if stdout wasn't already set in result
        return ProcessExecutionResult(
            exitCode: result.exitCode,
            stdout: collectedStdout.isEmpty ? result.stdout : collectedStdout,
            stderr: result.stderr,
            duration: result.duration
        )
    }

    // MARK: - Streaming Execution

    /// Launches a subprocess and returns an `AsyncStream<String>` of stdout/stderr lines alongside a Task tracking execution completion.
    public func stream(
        config: ProcessExecutionConfig
    ) -> (stream: AsyncStream<String>, processTask: Task<ProcessExecutionResult, Error>) {
        let (stream, continuation) = AsyncStream.makeStream(of: String.self)

        let executionTask = Task<ProcessExecutionResult, Error> {
            guard FileManager.default.isExecutableFile(atPath: config.executableURL.path) else {
                continuation.finish()
                throw ProcessRunnerError.executableNotFound(config.executableURL.path)
            }

            let process = Process()
            process.executableURL = config.executableURL
            process.arguments = config.arguments
            if let environment = config.environment {
                process.environment = environment
            }
            if let currentDirectoryURL = config.currentDirectoryURL {
                process.currentDirectoryURL = currentDirectoryURL
            }

            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe

            let startTime = Date()

            do {
                try process.run()
            } catch {
                continuation.finish()
                throw ProcessRunnerError.launchFailed(error.localizedDescription)
            }

            let pid = process.processIdentifier
            let pgid = getpgid(pid)
            let actualPGID = pgid > 0 ? pgid : pid

            // Close write ends in parent process immediately so readers get clean EOF on process exit
            try? stdoutPipe.fileHandleForWriting.close()
            try? stderrPipe.fileHandleForWriting.close()

            let registryHandleId = await self.registry.register(
                pid: pid,
                pgid: actualPGID,
                serviceId: config.serviceId,
                providerId: config.providerId,
                command: "\(config.executableURL.lastPathComponent) \(config.arguments.joined(separator: " "))"
            )

            // Explicit file descriptor reading handle pipe deferral to prevent descriptor leaks (errno 24)
            defer {
                try? stdoutPipe.fileHandleForReading.close()
                try? stderrPipe.fileHandleForReading.close()
                
                Task {
                    await self.registry.unregister(handleId: registryHandleId)
                }
            }

            let stderrBuffer = AsyncStderrCollector()

            // Asynchronously read stdout lines non-blockingly and yield to stream
            let stdoutReadTask = Task {
                let handle = stdoutPipe.fileHandleForReading
                var buffer = Data()

                while true {
                    if Task.isCancelled { break }
                    let data = handle.availableData
                    if data.isEmpty { break }
                    buffer.append(data)

                    while let newlineIndex = buffer.firstIndex(of: UInt8(ascii: "\n")) {
                        let lineData = buffer.subdata(in: 0..<newlineIndex)
                        if let line = String(data: lineData, encoding: .utf8) {
                            continuation.yield(line)
                        }
                        buffer.removeSubrange(0...newlineIndex)
                    }
                }

                // Yield remaining buffer content
                if !buffer.isEmpty, let line = String(data: buffer, encoding: .utf8) {
                    continuation.yield(line)
                }
            }

            // Asynchronously read stderr lines for error reporting
            let stderrReadTask = Task {
                let handle = stderrPipe.fileHandleForReading
                var buffer = Data()

                while true {
                    if Task.isCancelled { break }
                    let data = handle.availableData
                    if data.isEmpty { break }
                    buffer.append(data)
                }

                if let stderrString = String(data: buffer, encoding: .utf8) {
                    await stderrBuffer.append(stderrString)
                }
            }

            // Wait for process completion while supporting task cancellation
            while process.isRunning {
                if Task.isCancelled {
                    process.terminate()
                    await self.registry.terminateProcessGroup(pgid: actualPGID)
                    stdoutReadTask.cancel()
                    stderrReadTask.cancel()
                    continuation.finish()
                    throw ProcessRunnerError.cancelled
                }
                try? await Task.sleep(nanoseconds: 50_000_000) // 50ms polling
            }

            await stdoutReadTask.value
            await stderrReadTask.value
            continuation.finish()

            let duration = Date().timeIntervalSince(startTime)
            let capturedStderr = await stderrBuffer.getValue()
            let exitCode = process.terminationStatus

            self.logger.info("Process finished [PID: \(pid), ExitCode: \(exitCode), Duration: \(duration)s]")

            if exitCode != 0 {
                throw ProcessRunnerError.executionTerminated(exitCode: exitCode, stderr: capturedStderr)
            }

            return ProcessExecutionResult(
                exitCode: exitCode,
                stdout: "",
                stderr: capturedStderr,
                duration: duration
            )
        }

        return (stream, executionTask)
    }
}

// Helper actor for thread-safe stderr collection during streaming
private actor AsyncStderrCollector {
    private var value: String = ""

    func append(_ text: String) {
        value += text
    }

    func getValue() -> String {
        value
    }
}
