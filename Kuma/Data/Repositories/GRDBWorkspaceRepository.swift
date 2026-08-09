//
//  GRDBWorkspaceRepository.swift
//  Kuma
//
//  Created for Task 3.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB
import os

/// Concrete implementation of `WorkspaceRepositoryProtocol` backed by GRDB SQLite database.
public final class GRDBWorkspaceRepository: WorkspaceRepositoryProtocol, Sendable {
    
    private let dbWriter: any DatabaseWriter
    private nonisolated static let logger = Logger(subsystem: "com.kuma.app", category: "Database")

    public init(dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
    }

    public func fetchWorkspaces() async throws -> [Workspace] {
        try await dbWriter.read { db in
            let records = try WorkspaceRecord
                .order(Column("sort_order").asc, Column("name").asc)
                .fetchAll(db)
            return records.map(\.toDomain)
        }
    }

    public func fetchWorkspace(id: UUID) async throws -> Workspace? {
        try await dbWriter.read { db in
            let record = try WorkspaceRecord.fetchOne(db, key: id)
            return record?.toDomain
        }
    }

    public func saveWorkspace(_ workspace: Workspace) async throws {
        try await dbWriter.write { db in
            var record = WorkspaceRecord(from: workspace)
            record.updatedAt = Date()
            try record.save(db)
            Self.logger.debug("Saved workspace: \(workspace.name, privacy: .public) (\(workspace.id))")
        }
    }

    public func saveWorkspaces(_ workspaces: [Workspace]) async throws {
        try await dbWriter.write { db in
            let now = Date()
            for workspace in workspaces {
                var record = WorkspaceRecord(from: workspace)
                record.updatedAt = now
                try record.save(db)
            }
            Self.logger.debug("Batch saved \(workspaces.count, privacy: .public) workspaces")
        }
    }

    public func deleteWorkspace(id: UUID) async throws {
        try await dbWriter.write { db in
            let deleted = try WorkspaceRecord.deleteOne(db, key: id)
            if deleted {
                Self.logger.debug("Deleted workspace ID: \(id)")
            } else {
                Self.logger.warning("Attempted to delete non-existent workspace ID: \(id)")
            }
        }
    }
}
