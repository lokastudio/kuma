//
//  ServiceGroupRecord.swift
//  Kuma
//
//  Created for Task 3.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB

/// GRDB Record mapping `service_groups` SQLite table to `ServiceGroup` domain model.
public struct ServiceGroupRecord: Codable, FetchableRecord, PersistableRecord, TableRecord, Sendable {
    public static let databaseTableName = "service_groups"

    public var id: UUID
    public var workspaceId: UUID
    public var name: String
    public var sortOrder: Int
    public var createdAt: Date
    public var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case workspaceId = "workspace_id"
        case name
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public init(
        id: UUID,
        workspaceId: UUID,
        name: String,
        sortOrder: Int,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.workspaceId = workspaceId
        self.name = name
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Convert from domain model
    public init(from domain: ServiceGroup) {
        self.id = domain.id
        self.workspaceId = domain.workspaceId
        self.name = domain.name
        self.sortOrder = domain.sortOrder
        self.createdAt = domain.createdAt
        self.updatedAt = domain.updatedAt
    }

    /// Convert to domain model
    public nonisolated var toDomain: ServiceGroup {
        ServiceGroup(
            id: id,
            workspaceId: workspaceId,
            name: name,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
