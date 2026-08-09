//
//  WorkspaceRecord.swift
//  Kuma
//
//  Created for Task 3.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB

/// GRDB Record mapping `workspaces` SQLite table to `Workspace` domain model.
public struct WorkspaceRecord: Codable, FetchableRecord, PersistableRecord, TableRecord, Sendable {
    public static let databaseTableName = "workspaces"

    public var id: UUID
    public var name: String
    public var imagePath: String?
    public var sortOrder: Int
    public var createdAt: Date
    public var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imagePath = "image_path"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public init(
        id: UUID,
        name: String,
        imagePath: String?,
        sortOrder: Int,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Convert from domain model
    public init(from domain: Workspace) {
        self.id = domain.id
        self.name = domain.name
        self.imagePath = domain.imagePath
        self.sortOrder = domain.sortOrder
        self.createdAt = domain.createdAt
        self.updatedAt = domain.updatedAt
    }

    /// Convert to domain model
    public nonisolated var toDomain: Workspace {
        Workspace(
            id: id,
            name: name,
            imagePath: imagePath,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
