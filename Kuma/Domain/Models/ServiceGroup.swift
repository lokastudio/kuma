//
//  ServiceGroup.swift
//  Kuma
//
//  Created for Task 2.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Pure domain model representing a custom folder/group of services within a Workspace.
public struct ServiceGroup: Identifiable, Codable, Sendable, Equatable, Hashable {
    public let id: UUID
    public var workspaceId: UUID
    public var name: String
    public var sortOrder: Int
    public let createdAt: Date
    public var updatedAt: Date

    public nonisolated init(
        id: UUID = UUID(),
        workspaceId: UUID,
        name: String,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.workspaceId = workspaceId
        self.name = name
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
