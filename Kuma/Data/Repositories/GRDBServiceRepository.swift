//
//  GRDBServiceRepository.swift
//  Kuma
//
//  Created for Task 3.4 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB
import os

/// Concrete implementation of `ServiceRepositoryProtocol` backed by GRDB SQLite database.
public final class GRDBServiceRepository: ServiceRepositoryProtocol, Sendable {
    
    private let dbWriter: any DatabaseWriter
    private let logger = Logger(subsystem: "com.kuma.app", category: "Database")

    public init(dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
    }

    public func fetchServices(forWorkspaceId workspaceId: UUID) async throws -> [Service] {
        try await dbWriter.read { db in
            let records = try ServiceRecord
                .filter(Column("workspace_id") == workspaceId)
                .order(Column("sort_order").asc, Column("name").asc)
                .fetchAll(db)
            return records.map(\.toDomain)
        }
    }

    public func fetchServices(forGroupId groupId: UUID) async throws -> [Service] {
        try await dbWriter.read { db in
            let records = try ServiceRecord
                .filter(Column("group_id") == groupId)
                .order(Column("sort_order").asc, Column("name").asc)
                .fetchAll(db)
            return records.map(\.toDomain)
        }
    }

    public func fetchFavoriteServices() async throws -> [Service] {
        try await dbWriter.read { db in
            let records = try ServiceRecord
                .filter(Column("is_favorite") == true)
                .order(Column("name").asc)
                .fetchAll(db)
            return records.map(\.toDomain)
        }
    }

    public func fetchService(id: UUID) async throws -> Service? {
        try await dbWriter.read { db in
            let record = try ServiceRecord.fetchOne(db, key: id)
            return record?.toDomain
        }
    }

    public func saveService(_ service: Service) async throws {
        try await dbWriter.write { db in
            var record = ServiceRecord(from: service)
            record.updatedAt = Date()
            try record.save(db)
            self.logger.debug("Saved service: \(service.name, privacy: .public) (\(service.id))")
        }
    }

    public func saveServices(_ services: [Service]) async throws {
        try await dbWriter.write { db in
            try db.inTransaction {
                let now = Date()
                for service in services {
                    var record = ServiceRecord(from: service)
                    record.updatedAt = now
                    try record.save(db)
                }
                return .commit
            }
            self.logger.debug("Batch saved \(services.count, privacy: .public) services atomically")
        }
    }

    public func updateStatus(id: UUID, status: ServiceExecutionState, lastActivePort: Int?) async throws {
        let statusString = status.dbStatusString
        try await dbWriter.write { db in
            let now = Date()
            try db.execute(
                sql: """
                UPDATE services 
                SET last_status = ?, last_active_port = ?, updated_at = ? 
                WHERE id = ?
                """,
                arguments: [statusString, lastActivePort, now, id.uuidString]
            )
            self.logger.debug("Updated service status to \(statusString, privacy: .public) for ID: \(id)")
        }
    }

    public func updateActiveProvider(id: UUID, providerId: UUID?) async throws {
        try await dbWriter.write { db in
            let now = Date()
            try db.execute(
                sql: """
                UPDATE services 
                SET active_provider_id = ?, updated_at = ? 
                WHERE id = ?
                """,
                arguments: [providerId?.uuidString, now, id.uuidString]
            )
            self.logger.debug("Updated active provider for service ID: \(id)")
        }
    }

    public func updateGroup(serviceId: UUID, groupId: UUID?) async throws {
        try await dbWriter.write { db in
            let now = Date()
            try db.execute(
                sql: """
                UPDATE services 
                SET group_id = ?, updated_at = ? 
                WHERE id = ?
                """,
                arguments: [groupId?.uuidString, now, serviceId.uuidString]
            )
            self.logger.debug("Updated group assignment for service ID: \(serviceId)")
        }
    }

    public func updateSortOrders(_ updates: [(id: UUID, sortOrder: Int)]) async throws {
        try await dbWriter.write { db in
            try db.inTransaction {
                let now = Date()
                for (id, sortOrder) in updates {
                    try db.execute(
                        sql: """
                        UPDATE services 
                        SET sort_order = ?, updated_at = ? 
                        WHERE id = ?
                        """,
                        arguments: [sortOrder, now, id.uuidString]
                    )
                }
                return .commit
            }
            self.logger.debug("Updated sort orders for \(updates.count, privacy: .public) services atomically")
        }
    }

    public func resetAllStatusesToStopped() async throws {
        try await dbWriter.write { db in
            let now = Date()
            try db.execute(
                sql: """
                UPDATE services 
                SET last_status = 'stopped', updated_at = ? 
                WHERE last_status IN ('starting', 'running', 'stopping')
                """,
                arguments: [now]
            )
            self.logger.info("Restored service execution states back to 'stopped' on boot")
        }
    }

    public func deleteService(id: UUID) async throws {
        try await dbWriter.write { db in
            let deleted = try ServiceRecord.deleteOne(db, key: id)
            if deleted {
                self.logger.debug("Deleted service ID: \(id)")
            } else {
                self.logger.warning("Attempted to delete non-existent service ID: \(id)")
            }
        }
    }
}
