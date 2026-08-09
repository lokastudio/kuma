//
//  KubeConfigRecord.swift
//  Kuma
//
//  Created for Task 3.5 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB

/// GRDB Record mapping `kubeconfigs` SQLite table to `KubeConfig` domain model.
public struct KubeConfigRecord: Codable, FetchableRecord, PersistableRecord, TableRecord, Sendable {
    public static let databaseTableName = "kubeconfigs"

    public var id: UUID
    public var name: String
    public var path: String
    public var bookmarkData: Data?
    public var configContentEncrypted: Data?
    public var isDefault: Bool
    public var createdAt: Date
    public var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case path
        case bookmarkData = "bookmark_data"
        case configContentEncrypted = "config_content_encrypted"
        case isDefault = "is_default"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public init(
        id: UUID,
        name: String,
        path: String,
        bookmarkData: Data? = nil,
        configContentEncrypted: Data? = nil,
        isDefault: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.bookmarkData = bookmarkData
        self.configContentEncrypted = configContentEncrypted
        self.isDefault = isDefault
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Convert from domain model
    public init(from domain: KubeConfig) {
        self.id = domain.id
        self.name = domain.name
        self.path = domain.path
        self.bookmarkData = domain.bookmarkData
        self.configContentEncrypted = domain.configContentEncrypted
        self.isDefault = domain.isDefault
        self.createdAt = domain.createdAt
        self.updatedAt = domain.updatedAt
    }

    /// Convert to domain model
    public nonisolated var toDomain: KubeConfig {
        KubeConfig(
            id: id,
            name: name,
            path: path,
            bookmarkData: bookmarkData,
            configContentEncrypted: configContentEncrypted,
            isDefault: isDefault,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
