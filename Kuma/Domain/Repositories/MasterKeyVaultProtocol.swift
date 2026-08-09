//
//  MasterKeyVaultProtocol.swift
//  Kuma
//
//  Created for Task 3.6 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import CryptoKit

/// Protocol defining operations for local master key derivation and secret encryption/decryption.
public protocol MasterKeyVaultProtocol: Sendable {
    /// Retrieves or generates the 256-bit AES master key.
    func getOrCreateMasterKey() async throws -> SymmetricKey
    
    /// Encrypts plaintext string using AES-256-GCM.
    func encrypt(plainText: String) async throws -> (cipherTextBase64: String, nonceBase64: String)
    
    /// Decrypts AES-256-GCM encrypted payload back into plaintext string.
    func decrypt(cipherTextBase64: String, nonceBase64: String) async throws -> String
}
