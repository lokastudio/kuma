//
//  GRDBVaultSecretRepository.swift
//  Kuma
//
//  Created for Task 3.6 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB
import os

/// Repository for handling `VaultSecret` GRDB operations and transparent encryption/decryption.
public final class GRDBVaultSecretRepository: VaultSecretRepositoryProtocol, @unchecked Sendable {
    
    private let dbManager: DatabaseManager
    private let masterKeyVault: MasterKeyVaultProtocol
    private let logger = Logger(subsystem: "com.kuma.app", category: "VaultSecretRepository")

    public init(
        dbManager: DatabaseManager,
        masterKeyVault: MasterKeyVaultProtocol
    ) {
        self.dbManager = dbManager
        self.masterKeyVault = masterKeyVault
    }

    public func fetchSecret(id: UUID) async throws -> VaultSecret? {
        let idString = id.uuidString
        return try await dbManager.dbWriter.read { db in
            guard let record = try VaultSecretRecord.fetchOne(db, key: idString) else {
                return nil
            }
            return record.toDomain
        }
    }

    public func fetchSecrets(forProvider providerId: UUID) async throws -> [VaultSecret] {
        let providerIdString = providerId.uuidString
        return try await dbManager.dbWriter.read { db in
            let records = try VaultSecretRecord
                .filter(Column("provider_id") == providerIdString)
                .fetchAll(db)
            return records.compactMap { $0.toDomain }
        }
    }

    public func saveSecret(_ secret: VaultSecret, plainTextValue: String) async throws -> VaultSecret {
        let (cipherTextBase64, nonceBase64) = try await masterKeyVault.encrypt(plainText: plainTextValue)
        
        var updatedSecret = secret
        updatedSecret.ciphertextBase64 = cipherTextBase64
        updatedSecret.nonceBase64 = nonceBase64
        updatedSecret.updatedAt = Date()
        
        let record = VaultSecretRecord(from: updatedSecret)
        
        try await dbManager.dbWriter.write { db in
            try record.save(db)
        }
        
        logger.info("Successfully persisted encrypted VaultSecret \(updatedSecret.id.uuidString, privacy: .public)")
        return updatedSecret
    }

    public func deleteSecret(id: UUID) async throws {
        let idString = id.uuidString
        _ = try await dbManager.dbWriter.write { db in
            try VaultSecretRecord.deleteOne(db, key: idString)
        }
        logger.info("Deleted VaultSecret \(idString, privacy: .public)")
    }

    public func decryptValue(for secret: VaultSecret) async throws -> String {
        return try await masterKeyVault.decrypt(
            cipherTextBase64: secret.ciphertextBase64,
            nonceBase64: secret.nonceBase64
        )
    }
}
