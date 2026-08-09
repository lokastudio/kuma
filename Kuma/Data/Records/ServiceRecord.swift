//
//  ServiceRecord.swift
//  Kuma
//
//  Created for Task 3.4 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB

/// GRDB Record mapping `services` SQLite table to `Service` domain model.
public struct ServiceRecord: Codable, FetchableRecord, PersistableRecord, TableRecord, Sendable {
    public static let databaseTableName = "services"

    public var id: UUID
    public var workspaceId: UUID
    public var groupId: UUID?
    public var name: String
    public var description: String?
    public var isDisabled: Bool
    public var isFavorite: Bool
    public var activeProviderId: UUID?
    public var lastStatus: String
    public var lastActivePort: Int?
    public var sortOrder: Int
    public var createdAt: Date
    public var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case workspaceId = "workspace_id"
        case groupId = "group_id"
        case name
        case description
        case isDisabled = "is_disabled"
        case isFavorite = "is_favorite"
        case activeProviderId = "active_provider_id"
        case lastStatus = "last_status"
        case lastActivePort = "last_active_port"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public init(
        id: UUID,
        workspaceId: UUID,
        groupId: UUID?,
        name: String,
        description: String?,
        isDisabled: Bool,
        isFavorite: Bool,
        activeProviderId: UUID?,
        lastStatus: String,
        lastActivePort: Int?,
        sortOrder: Int,
        createdAt: Date,
        updatedAt: Date
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

    /// Convert from domain model
    public init(from domain: Service) {
        self.id = domain.id
        self.workspaceId = domain.workspaceId
        self.groupId = domain.groupId
        self.name = domain.name
        self.description = domain.description
        self.isDisabled = domain.isDisabled
        self.isFavorite = domain.isFavorite
        self.activeProviderId = domain.activeProviderId
        self.lastStatus = domain.lastStatus.dbStatusString
        self.lastActivePort = domain.lastActivePort
        self.sortOrder = domain.sortOrder
        self.createdAt = domain.createdAt
        self.updatedAt = domain.updatedAt
    }

    /// Convert to domain model
    public nonisolated var toDomain: Service {
        let state: ServiceExecutionState
        switch lastStatus {
        case "running":
            state = .running(pid: 0, activePort: lastActivePort ?? 0)
        case "failed":
            state = .failed(error: "Previous session failed")
        default:
            state = .stopped
        }

        return Service(
            id: id,
            workspaceId: workspaceId,
            groupId: groupId,
            name: name,
            description: description,
            isDisabled: isDisabled,
            isFavorite: isFavorite,
            activeProviderId: activeProviderId,
            lastStatus: state,
            lastActivePort: lastActivePort,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
