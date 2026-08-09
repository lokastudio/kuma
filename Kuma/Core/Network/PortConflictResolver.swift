//
//  PortConflictResolver.swift
//  Kuma
//
//  Created for Task 4.7 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import Foundation
import os
import Darwin

/// Actor responsible for detecting PID port conflicts via `/usr/sbin/lsof`, 
/// suggesting auto-free alternative ports, and terminating blocking processes cleanly.
public actor PortConflictResolver: PortConflictResolverProtocol {
    private let logger = Logger(subsystem: "com.kuma.app", category: "PortConflictResolver")
    private let runner: ProcessRunner
    private let pathResolver: EnvironmentPathResolver

    public init(
        runner: ProcessRunner = ProcessRunner(),
        pathResolver: EnvironmentPathResolver = EnvironmentPathResolver.shared
    ) {
        self.runner = runner
        self.pathResolver = pathResolver
    }

    // MARK: - Port Availability Check

    /// Checks if a TCP port is open and available locally.
    public func checkPortAvailability(port: Int) async -> Bool {
        guard port > 0 && port <= 65535 else { return false }
        
        let conflict = await inspectConflict(port: port)
        if conflict != nil {
            return false
        }
        
        // Secondary binding test using BSD sockets to verify port binding capacity
        return isSocketAvailable(port: UInt16(port))
    }

    // MARK: - Conflict Inspection

    /// Inspects the process currently occupying the specified port via `/usr/sbin/lsof`.
    public func inspectConflict(port: Int) async -> PortConflictInfo? {
        let lsofPath = await pathResolver.resolveExecutablePath(for: "lsof") ?? "/usr/sbin/lsof"
        let executableURL = URL(fileURLWithPath: lsofPath)

        guard FileManager.default.isExecutableFile(atPath: lsofPath) else {
            logger.error("lsof executable unavailable at path: \(lsofPath)")
            return nil
        }

        let config = ProcessExecutionConfig(
            executableURL: executableURL,
            arguments: ["-iTCP:\(port)", "-sTCP:LISTEN", "-n", "-P"]
        )

        do {
            let result = try await runner.run(config: config)
            guard result.exitCode == 0, !result.stdout.isEmpty else {
                return nil
            }
            return parseLsofOutput(result.stdout, targetPort: port)
        } catch {
            logger.debug("No active process listener found on port \(port): \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Port Suggestion

    /// Suggests an available TCP port starting from the requested baseline port up to `maxAttempts`.
    public func suggestAvailablePort(startingFrom port: Int, maxAttempts: Int = 100) async -> Int {
        let basePort = max(1024, min(65535, port))
        
        for offset in 0..<maxAttempts {
            let candidatePort = basePort + offset
            if candidatePort > 65535 { break }
            
            if await checkPortAvailability(port: candidatePort) {
                return candidatePort
            }
        }
        
        // Fallback: search downwards if upward search exhausted
        for offset in 1...maxAttempts {
            let candidatePort = basePort - offset
            if candidatePort < 1024 { break }
            
            if await checkPortAvailability(port: candidatePort) {
                return candidatePort
            }
        }

        return basePort
    }

    // MARK: - Process Termination

    /// Kills the process occupying the specified port using `SIGTERM` or `SIGKILL`.
    public func killProcessOccupyingPort(_ conflict: PortConflictInfo, force: Bool = false) async -> Bool {
        let pid = conflict.pid
        guard pid > 1 else {
            logger.error("Refusing to terminate system PID \(pid)")
            return false
        }

        let signal = force ? SIGKILL : SIGTERM
        logger.info("Sending signal \(signal) to process \(conflict.processName) [PID: \(pid)] on port \(conflict.port)")

        let result = kill(pid, signal)
        if result == 0 {
            // Verify process exit within 300ms window
            try? await Task.sleep(nanoseconds: 300_000_000)
            let stillOccupied = await inspectConflict(port: conflict.port)
            if stillOccupied?.pid == pid {
                if !force {
                    logger.warning("PID \(pid) ignored SIGTERM; retrying with SIGKILL")
                    return await killProcessOccupyingPort(conflict, force: true)
                }
                return false
            }
            return true
        } else {
            let err = errno
            logger.error("Failed to send signal \(signal) to PID \(pid), errno: \(err)")
            return false
        }
    }

    // MARK: - Output Parsing & Helpers

    /// Parses output from `/usr/sbin/lsof -iTCP:<port> -sTCP:LISTEN -n -P`.
    /// Example output line:
    /// `COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME`
    /// `postgres 1234 user    3u  IPv4 0x1234      0t0  TCP *:5432 (LISTEN)`
    private func parseLsofOutput(_ output: String, targetPort: Int) -> PortConflictInfo? {
        let lines = output.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard lines.count >= 2 else { return nil }

        // Skip header line (index 0) and evaluate first listener process entry
        for line in lines.dropFirst() {
            let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            guard components.count >= 3 else { continue }

            let processName = components[0]
            guard let pid = Int32(components[1]) else { continue }
            let user = components[2]

            return PortConflictInfo(
                port: targetPort,
                pid: pid,
                processName: processName,
                commandLine: line,
                user: user
            )
        }

        return nil
    }

    /// Direct low-level BSD socket binding attempt to verify port availability.
    private func isSocketAvailable(port: UInt16) -> Bool {
        let socketFD = socket(AF_INET, SOCK_STREAM, 0)
        guard socketFD >= 0 else { return false }
        
        defer {
            close(socketFD)
        }

        var addr = sockaddr_in()
        addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = port.bigEndian
        addr.sin_addr.s_addr = INADDR_ANY.bigEndian

        let bindResult = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { saPtr in
                bind(socketFD, saPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        return bindResult == 0
    }
}
