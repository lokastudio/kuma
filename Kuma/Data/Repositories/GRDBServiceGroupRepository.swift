//
//  GRDBServiceGroupRepository.swift
//  Kuma
//
//  Created for Task 3.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB
import os

/// Concrete implementation of `ServiceGroupRepositoryProtocol` backed by GRDB SQLite database.
public final class GRDBServiceGroupRepository: ServiceGroupRepositoryProtocol, Sendable {
    
    private let dbWriter: any DatabaseWriter
    private nonisolated static let logger = Logger(subsystem: "com.kuma.app", category: "Database")

    public init(dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
    }

    public func fetchServiceGroups(forWorkspaceId workspaceId: UUID) async throws -> [ServiceGroup] {
        try await dbWriter.read { db in
            let records = try ServiceGroupRecord
                .filter(Column("workspace_id") == workspaceId)
                .order(Column("sort_order").asc, Column("name").asc)
                .fetchAll(db)
            return records.map(\.toDomain)
        }
    }

    public func fetchServiceGroup(id: UUID) async throws -> ServiceGroup? {
        try await dbWriter.read { db in
            let record = try ServiceGroupRecord.fetchOne(db, key: id)
            return record?.toDomain
        }
    }

    public func saveServiceGroup(_ group: ServiceGroup) async throws {
        try await dbWriter.write { db in
            var record = ServiceGroupRecord(from: group)
            record.updatedAt = Date()
            try record.save(db)
            Self.logger.debug("Saved service group: \(group.name, privacy: .public) (\(group.id))")
        }
    }

    public func saveServiceGroups(_ groups: [ServiceGroup]) async throws {
        try await dbWriter.write { db in
            let now = Date()
            for group in groups {
                var record = ServiceGroupRecord(from: group)
                record.updatedAt = now
                try record.save(db)
            }
            Self.logger.debug("Batch saved \(groups.count, privacy: .public) service groups")
        }
    }

    public func deleteServiceGroup(id: UUID) async throws {
        try await dbWriter.write { db in
            let deleted = try ServiceGroupRecord.deleteOne(db, key: id)
            if deleted {
                Self.logger.debug("Deleted service group ID: \(id)")
            } else {
                Self.logger.warning("Attempted to delete non-existent service group ID: \(id)")
            }
        }
    }
}
