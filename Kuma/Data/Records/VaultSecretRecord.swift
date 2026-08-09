//
//  VaultSecretRecord.swift
//  Kuma
//
//  Created for Task 3.6 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB

/// GRDB Record representation of the `vault_secrets` database table.
public struct VaultSecretRecord: Codable, FetchableRecord, PersistableRecord, Sendable, Equatable {
    public static let databaseTableName = "vault_secrets"

    public var id: String
    public var provider_id: String
    public var secret_type: String
    public var ciphertext_base64: String
    public var nonce_base64: String
    public var updated_at: Date

    public init(
        id: String,
        provider_id: String,
        secret_type: String,
        ciphertext_base64: String,
        nonce_base64: String,
        updated_at: Date
    ) {
        self.id = id
        self.provider_id = provider_id
        self.secret_type = secret_type
        self.ciphertext_base64 = ciphertext_base64
        self.nonce_base64 = nonce_base64
        self.updated_at = updated_at
    }

    public init(from domain: VaultSecret) {
        self.id = domain.id.uuidString
        self.provider_id = domain.providerId.uuidString
        self.secret_type = domain.secretType.rawValue
        self.ciphertext_base64 = domain.ciphertextBase64
        self.nonce_base64 = domain.nonceBase64
        self.updated_at = domain.updatedAt
    }

    public nonisolated var toDomain: VaultSecret? {
        guard let uuid = UUID(uuidString: id),
              let providerUUID = UUID(uuidString: provider_id),
              let type = VaultSecret.SecretType(rawValue: secret_type) else {
            return nil
        }
        return VaultSecret(
            id: uuid,
            providerId: providerUUID,
            secretType: type,
            ciphertextBase64: ciphertext_base64,
            nonceBase64: nonce_base64,
            updatedAt: updated_at
        )
    }
}
