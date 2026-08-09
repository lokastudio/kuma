//
//  VaultSecret.swift
//  Kuma
//
//  Created for Task 2.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Pure domain model representing an encrypted credential/secret linked to a Provider.
public struct VaultSecret: Identifiable, Codable, Sendable, Equatable, Hashable {
    
    /// Discriminator type for stored secrets.
    public enum SecretType: String, Codable, Sendable, CaseIterable {
        case sshPassword = "ssh_password"
        case sshPrivateKey = "ssh_private_key"
        case authToken = "auth_token"
    }

    public let id: UUID
    public var providerId: UUID
    public var secretType: SecretType
    public var ciphertextBase64: String
    public var nonceBase64: String
    public var updatedAt: Date

    public nonisolated init(
        id: UUID = UUID(),
        providerId: UUID,
        secretType: SecretType,
        ciphertextBase64: String,
        nonceBase64: String,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.providerId = providerId
        self.secretType = secretType
        self.ciphertextBase64 = ciphertextBase64
        self.nonceBase64 = nonceBase64
        self.updatedAt = updatedAt
    }
}
