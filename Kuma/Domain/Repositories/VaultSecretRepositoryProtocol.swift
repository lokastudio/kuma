//
//  VaultSecretRepositoryProtocol.swift
//  Kuma
//
//  Created for Task 3.6 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Protocol defining async repository CRUD operations for encrypted VaultSecrets.
public protocol VaultSecretRepositoryProtocol: Sendable {
    /// Fetches a secret by its UUID.
    func fetchSecret(id: UUID) async throws -> VaultSecret?
    
    /// Fetches all secrets associated with a specific Provider UUID.
    func fetchSecrets(forProvider providerId: UUID) async throws -> [VaultSecret]
    
    /// Encrypts and persists a new secret or updates an existing one.
    func saveSecret(_ secret: VaultSecret, plainTextValue: String) async throws -> VaultSecret
    
    /// Deletes a secret by its UUID.
    func deleteSecret(id: UUID) async throws
    
    /// Decrypts the secret payload back into plaintext string.
    func decryptValue(for secret: VaultSecret) async throws -> String
}
