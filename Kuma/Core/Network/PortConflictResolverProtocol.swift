//
//  PortConflictResolverProtocol.swift
//  Kuma
//
//  Created for Task 4.7 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import Foundation

/// Protocol defining port inspection, availability checks, port suggestions, and auto-free operations.
public protocol PortConflictResolverProtocol: Actor {
    /// Checks whether the given local TCP port is currently free to bind.
    func checkPortAvailability(port: Int) async -> Bool

    /// Inspects the process currently occupying the specified local TCP port, if any.
    func inspectConflict(port: Int) async -> PortConflictInfo?

    /// Suggests the next available local TCP port starting from a baseline port.
    func suggestAvailablePort(startingFrom port: Int, maxAttempts: Int) async -> Int

    /// Terminates the process occupying the specified port using SIGTERM/SIGKILL.
    func killProcessOccupyingPort(_ conflict: PortConflictInfo, force: Bool) async -> Bool
}

extension PortConflictResolverProtocol {
    public func suggestAvailablePort(startingFrom port: Int) async -> Int {
        await suggestAvailablePort(startingFrom: port, maxAttempts: 100)
    }
}
