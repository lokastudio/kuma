//
//  DependencyCheckResult.swift
//  Kuma
//
//  Created for Task 2.4 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Pure domain enum modeling system binary detection check results.
public enum DependencyCheckResult: Codable, Sendable, Equatable, Hashable {
    case available(executablePath: String, version: String?)
    case missing(dependency: SystemDependency)
    case versionMismatch(dependency: SystemDependency, foundVersion: String, requiredVersion: String)

    public var isAvailable: Bool {
        if case .available = self {
            return true
        }
        return false
    }
}
