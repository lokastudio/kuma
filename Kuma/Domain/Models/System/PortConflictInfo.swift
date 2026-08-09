//
//  PortConflictInfo.swift
//  Kuma
//
//  Created for Task 4.7 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import Foundation

/// Pure domain model representing process information for an occupied local port.
public struct PortConflictInfo: Sendable, Equatable, Hashable, Identifiable {
    public var id: Int { port }
    public let port: Int
    public let pid: Int32
    public let processName: String
    public let commandLine: String?
    public let user: String?

    public nonisolated init(
        port: Int,
        pid: Int32,
        processName: String,
        commandLine: String? = nil,
        user: String? = nil
    ) {
        self.port = port
        self.pid = pid
        self.processName = processName
        self.commandLine = commandLine
        self.user = user
    }

    /// Human-centered error title according to `Docs/UX_SPECIFICATION.md`.
    public var uiTitle: String {
        "Port \(port) is Already in Use"
    }

    /// Action-oriented sub-text according to `Docs/UX_SPECIFICATION.md`.
    public var uiSubText: String {
        "Occupied by PID \(pid) (\(processName)). Click to auto-free or resolve."
    }
}
