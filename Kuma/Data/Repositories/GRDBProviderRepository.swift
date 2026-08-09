//
//  GRDBProviderRepository.swift
//  Kuma
//
//  Created for Task 3.5 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB

/// Concrete GRDB implementation of `ProviderRepositoryProtocol`.
public final class GRDBProviderRepository: ProviderRepositoryProtocol, Sendable {
    private let dbManager: DatabaseManager

    public init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
    }

    public func fetchProviders(forServiceId serviceId: UUID) async throws -> [Provider] {
        try await dbManager.dbWriter.read { db in
            let records = try ProviderRecord
                .filter(Column("service_id") == serviceId)
                .order(Column("created_at").asc)
                .fetchAll(db)
            return try records.map { try $0.toDomain() }
        }
    }

    public func fetchProvider(id: UUID) async throws -> Provider? {
        try await dbManager.dbWriter.read { db in
            guard let record = try ProviderRecord.fetchOne(db, key: id) else {
                return nil
            }
            return try record.toDomain()
        }
    }

    public func saveProvider(_ provider: Provider) async throws {
        let record = try ProviderRecord(from: provider)
        try await dbManager.dbWriter.write { db in
            try record.save(db)
        }
    }

    public func deleteProvider(id: UUID) async throws {
        _ = try await dbManager.dbWriter.write { db in
            try ProviderRecord.deleteOne(db, key: id)
        }
    }

    public func fetchPortMappings(forProviderId providerId: UUID) async throws -> [PortMapping] {
        try await dbManager.dbWriter.read { db in
            let records = try PortMappingRecord
                .filter(Column("provider_id") == providerId)
                .order(Column("created_at").asc)
                .fetchAll(db)
            return records.map(\.toDomain)
        }
    }

    public func savePortMappings(_ mappings: [PortMapping], forProviderId providerId: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            // Delete existing mappings for the provider
            try PortMappingRecord
                .filter(Column("provider_id") == providerId)
                .deleteAll(db)

            // Insert new mappings
            for mapping in mappings {
                var record = PortMappingRecord(from: mapping)
                record.providerId = providerId
                try record.insert(db)
            }
        }
    }
}
