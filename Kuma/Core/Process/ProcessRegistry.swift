//
//  ProcessRegistry.swift
//  Kuma
//
//  Created by Antigravity on 2026-08-09.
//

import Foundation
import os

/// Immutable metadata handle tracking a registered subprocess.
public struct ProcessHandle: Sendable, Identifiable, Hashable {
    public let id: UUID
    public let pid: pid_t
    public let pgid: pid_t
    public let serviceId: UUID
    public let providerId: UUID
    public let command: String
    public let startTime: Date

    public nonisolated init(
        id: UUID = UUID(),
        pid: pid_t,
        pgid: pid_t,
        serviceId: UUID,
        providerId: UUID,
        command: String,
        startTime: Date = Date()
    ) {
        self.id = id
        self.pid = pid
        self.pgid = pgid
        self.serviceId = serviceId
        self.providerId = providerId
        self.command = command
        self.startTime = startTime
    }
}

/// Thread-safe actor responsible for tracking spawned subprocess PIDs / PGIDs
/// and performing graceful termination protocols (`SIGINT` -> `SIGTERM` -> `SIGKILL`).
public actor ProcessRegistry {
    /// Shared singleton instance for global process governance.
    public static let shared = ProcessRegistry()

    private let logger = Logger(subsystem: "com.kuma.app", category: "ProcessEngine")
    private var processes: [UUID: ProcessHandle] = [:]

    public init() {}

    // MARK: - Process Registration & Queries

    /// Registers a newly spawned process in the registry.
    @discardableResult
    public func register(
        pid: pid_t,
        pgid: pid_t,
        serviceId: UUID,
        providerId: UUID,
        command: String
    ) -> UUID {
        let handle = ProcessHandle(
            pid: pid,
            pgid: pgid,
            serviceId: serviceId,
            providerId: providerId,
            command: command
        )
        processes[handle.id] = handle
        logger.info("Registered process [ID: \(handle.id.uuidString, privacy: .public), PID: \(pid), PGID: \(pgid)] for service: \(serviceId.uuidString, privacy: .public)")
        return handle.id
    }

    /// Removes a process handle from the registry (e.g. after clean exit).
    public func unregister(handleId: UUID) {
        if let removed = processes.removeValue(forKey: handleId) {
            logger.debug("Unregistered process [ID: \(handleId.uuidString, privacy: .public), PID: \(removed.pid)]")
        }
    }

    /// Returns a list of all currently tracked active processes.
    public func activeProcesses() -> [ProcessHandle] {
        Array(processes.values)
    }

    /// Returns all active processes associated with a given service ID.
    public func activeProcesses(forService serviceId: UUID) -> [ProcessHandle] {
        processes.values.filter { $0.serviceId == serviceId }
    }

    /// Returns a specific process handle if registered.
    public func process(forHandleId handleId: UUID) -> ProcessHandle? {
        processes[handleId]
    }

    // MARK: - Process Group Termination Protocol

    /// Executes the standard graceful process group termination sequence (`SIGINT` -> `SIGTERM` -> `SIGKILL`).
    /// - Parameters:
    ///   - pgid: Process Group ID to terminate (`setpgid`).
    ///   - gracefulTimeoutSeconds: Duration to wait after `SIGINT` before sending `SIGTERM`. Default: 2.0s.
    ///   - forceTimeoutSeconds: Duration to wait after `SIGTERM` before sending `SIGKILL`. Default: 1.5s.
    public func terminateProcessGroup(
        pgid: pid_t,
        gracefulTimeoutSeconds: Double = 2.0,
        forceTimeoutSeconds: Double = 1.5
    ) async {
        guard pgid > 1 else {
            logger.error("Refusing to terminate invalid process group ID: \(pgid)")
            return
        }

        logger.info("Starting graceful termination sequence for PGID: \(pgid)")

        // 1. Send SIGINT (Interrupt)
        sendSignal(signal: SIGINT, toPGID: pgid)

        if await waitForProcessGroupExit(pgid: pgid, timeoutSeconds: gracefulTimeoutSeconds) {
            logger.info("PGID \(pgid) terminated gracefully following SIGINT")
            cleanupProcesses(withPGID: pgid)
            return
        }

        // 2. Send SIGTERM (Terminate)
        logger.notice("PGID \(pgid) did not exit after SIGINT timeout. Sending SIGTERM...")
        sendSignal(signal: SIGTERM, toPGID: pgid)

        if await waitForProcessGroupExit(pgid: pgid, timeoutSeconds: forceTimeoutSeconds) {
            logger.info("PGID \(pgid) terminated following SIGTERM")
            cleanupProcesses(withPGID: pgid)
            return
        }

        // 3. Send SIGKILL (Force Kill)
        logger.error("PGID \(pgid) resistant to SIGTERM. Issuing SIGKILL...")
        sendSignal(signal: SIGKILL, toPGID: pgid)
        cleanupProcesses(withPGID: pgid)
    }

    /// Terminates a specific registered process handle.
    public func terminateProcess(handleId: UUID) async {
        guard let handle = processes[handleId] else { return }
        await terminateProcessGroup(pgid: handle.pgid)
    }

    /// Terminates all registered subprocesses across all services (e.g. during application quit).
    public func terminateAllProcesses() async {
        let allHandles = Array(processes.values)
        guard !allHandles.isEmpty else { return }

        logger.notice("Terminating all \(allHandles.count) registered subprocesses...")

        let uniquePGIDs = Set(allHandles.map(\.pgid))
        for pgid in uniquePGIDs {
            await terminateProcessGroup(pgid: pgid)
        }
        processes.removeAll()
    }

    // MARK: - Private Helpers

    /// Sends signal to process group `pgid`, falling back to single PID `kill` if `killpg` fails with `ESRCH`.
    private func sendSignal(signal: Int32, toPGID pgid: pid_t) {
        if killpg(pgid, signal) == 0 {
            logger.debug("Sent signal \(signal) to PGID \(pgid)")
        } else {
            let err = errno
            if err == ESRCH {
                // Process group lost or not group leader, attempt direct PID kill for matched handles
                let matchingPIDs = processes.values.filter { $0.pgid == pgid || $0.pid == pgid }.map(\.pid)
                for pid in matchingPIDs {
                    _ = kill(pid, signal)
                }
            } else {
                logger.warning("Failed to send signal \(signal) to PGID \(pgid): errno \(err)")
            }
        }
    }

    /// Polls non-blockingly until process group exits or timeout is reached.
    private func waitForProcessGroupExit(pgid: pid_t, timeoutSeconds: Double) async -> Bool {
        let intervalMicroseconds: UInt64 = 100_000 // 100ms
        let deadline = Date().addingTimeInterval(timeoutSeconds)

        while Date() < deadline {
            if Task.isCancelled {
                return false
            }

            // killpg with signal 0 checks if process group exists and process has permission to send signals
            if killpg(pgid, 0) != 0 {
                return true // Process group no longer exists
            }

            try? await Task.sleep(nanoseconds: intervalMicroseconds * 1_000)
        }

        return killpg(pgid, 0) != 0
    }

    private func cleanupProcesses(withPGID pgid: pid_t) {
        let toRemove = processes.filter { $0.value.pgid == pgid || $0.value.pid == pgid }.map(\.key)
        for key in toRemove {
            processes.removeValue(forKey: key)
        }
    }
}
