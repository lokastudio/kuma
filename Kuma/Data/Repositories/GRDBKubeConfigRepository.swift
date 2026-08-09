//
//  GRDBKubeConfigRepository.swift
//  Kuma
//
//  Created for Task 3.5 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB

/// Errors specific to KubeConfig database operations.
public enum KubeConfigRepositoryError: Error, LocalizedError, Sendable {
    case notFound(id: UUID)

    public var errorDescription: String? {
        switch self {
        case .notFound(let id):
            return "KubeConfig with ID '\(id)' was not found."
        }
    }
}

/// Concrete GRDB implementation of `KubeConfigRepositoryProtocol`.
public final class GRDBKubeConfigRepository: KubeConfigRepositoryProtocol, Sendable {
    private let dbManager: DatabaseManager

    public init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
    }

    public func fetchKubeConfigs() async throws -> [KubeConfig] {
        try await dbManager.dbWriter.read { db in
            let records = try KubeConfigRecord
                .order(Column("created_at").asc)
                .fetchAll(db)
            return records.map(\.toDomain)
        }
    }

    public func fetchKubeConfig(id: UUID) async throws -> KubeConfig? {
        try await dbManager.dbWriter.read { db in
            let record = try KubeConfigRecord.fetchOne(db, key: id)
            return record?.toDomain
        }
    }

    public func saveKubeConfig(_ kubeConfig: KubeConfig) async throws {
        let record = KubeConfigRecord(from: kubeConfig)
        try await dbManager.dbWriter.write { db in
            try record.save(db)
        }
    }

    public func deleteKubeConfig(id: UUID) async throws {
        _ = try await dbManager.dbWriter.write { db in
            try KubeConfigRecord.deleteOne(db, key: id)
        }
    }

    public func setDefaultKubeConfig(id: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            guard let record = try KubeConfigRecord.fetchOne(db, key: id) else {
                throw KubeConfigRepositoryError.notFound(id: id)
            }
            
            // Clear default flag on all configs
            try db.execute(
                sql: "UPDATE kubeconfigs SET is_default = 0, updated_at = ?",
                arguments: [Date()]
            )
            // Set default flag on targeted config
            var updatedRecord = record
            updatedRecord.isDefault = true
            updatedRecord.updatedAt = Date()
            try updatedRecord.save(db)
        }
    }
}
