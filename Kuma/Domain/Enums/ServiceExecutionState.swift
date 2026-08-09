//
//  ServiceExecutionState.swift
//  Kuma
//
//  Created for Task 2.1 in accordance with AGENTS.md & ROADMAP.md.
//

import Foundation

/// Pure domain state machine representing the execution status of a Service in Kuma.
/// Multi-boolean status flags are strictly forbidden per AGENTS.md.
/// Uses associated values for rich runtime execution data (PID, active port, progress, & error messages).
public enum ServiceExecutionState: Codable, Sendable, Equatable, Hashable {
    /// Service is completely idle or stopped cleanly.
    case stopped

    /// Subprocess spawning or port-forward initializing with optional progress subtext.
    case starting(progress: String = "Starting...")

    /// Service active and responding / process running with PID and bound active port.
    case running(pid: Int32 = 0, activePort: Int = 0)

    /// Graceful termination (`SIGINT`/`SIGTERM`) in progress.
    case stopping

    /// Execution or port-forward failed with user-facing error message.
    case failed(error: String)

    // MARK: - Database Persistence String Discriminator

    /// Simple stable status string for SQLite / GRDB persistence (`stopped`, `running`, `failed`).
    public nonisolated var dbStatusString: String {
        switch self {
        case .stopped: return "stopped"
        case .starting: return "stopped" // Transient fallback for DB restart
        case .running: return "running"
        case .stopping: return "stopped" // Transient fallback for DB restart
        case .failed: return "failed"
        }
    }

    // MARK: - Domain Computed Attributes

    /// Human-readable title for UI presentation.
    public var displayName: String {
        switch self {
        case .stopped:
            return "Stopped"
        case .starting(let progress):
            return progress
        case .running:
            return "Running"
        case .stopping:
            return "Stopping..."
        case .failed:
            return "Failed"
        }
    }

    /// Associated error message if state is `.failed`.
    public var errorMessage: String? {
        if case .failed(let err) = self {
            return err
        }
        return nil
    }

    /// Active PID if running.
    public var processID: Int32? {
        if case .running(let pid, _) = self, pid > 0 {
            return pid
        }
        return nil
    }

    /// Active local port if running.
    public var activePort: Int? {
        if case .running(_, let port) = self, port > 0 {
            return port
        }
        return nil
    }

    /// Indicates whether the service is actively occupying resources or running.
    public var isActive: Bool {
        switch self {
        case .starting, .running:
            return true
        case .stopped, .stopping, .failed:
            return false
        }
    }

    /// Indicates whether the service is in a transient state.
    public var isTransitioning: Bool {
        switch self {
        case .starting, .stopping:
            return true
        case .stopped, .running, .failed:
            return false
        }
    }
}
