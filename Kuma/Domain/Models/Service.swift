//
//  Service.swift
//  Kuma
//
//  Created for Task 2.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Pure domain model representing a Service in Kuma.
public struct Service: Identifiable, Codable, Sendable, Equatable, Hashable {
    public let id: UUID
    public var workspaceId: UUID
    public var groupId: UUID?
    public var name: String
    public var description: String?
    public var isDisabled: Bool
    public var isFavorite: Bool
    public var activeProviderId: UUID?
    public var lastStatus: ServiceExecutionState
    public var lastActivePort: Int?
    public var sortOrder: Int
    public let createdAt: Date
    public var updatedAt: Date

    public nonisolated init(
        id: UUID = UUID(),
        workspaceId: UUID,
        groupId: UUID? = nil,
        name: String,
        description: String? = nil,
        isDisabled: Bool = false,
        isFavorite: Bool = false,
        activeProviderId: UUID? = nil,
        lastStatus: ServiceExecutionState = .stopped,
        lastActivePort: Int? = nil,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.workspaceId = workspaceId
        self.groupId = groupId
        self.name = name
        self.description = description
        self.isDisabled = isDisabled
        self.isFavorite = isFavorite
        self.activeProviderId = activeProviderId
        self.lastStatus = lastStatus
        self.lastActivePort = lastActivePort
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
