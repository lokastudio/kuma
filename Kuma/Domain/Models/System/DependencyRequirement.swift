//
//  DependencyRequirement.swift
//  Kuma
//
//  Created for Task 2.4 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Pure domain struct defining a specific system dependency requirement.
public struct DependencyRequirement: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let id: UUID
    public var dependency: SystemDependency
    public var minVersion: String?
    public var isRequired: Bool

    public init(
        id: UUID = UUID(),
        dependency: SystemDependency,
        minVersion: String? = nil,
        isRequired: Bool = true
    ) {
        self.id = id
        self.dependency = dependency
        self.minVersion = minVersion
        self.isRequired = isRequired
    }
}
