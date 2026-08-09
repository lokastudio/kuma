//
//  MasterKeyVault.swift
//  Kuma
//
//  Created for Task 3.6 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import CryptoKit
import Security
import GRDB
import os

/// Error type for MasterKeyVault operations.
public enum MasterKeyVaultError: Error, LocalizedError, Sendable {
    case invalidUTF8
    case invalidBase64
    case payloadCorrupted
    case keychainReadError(status: OSStatus)
    case keychainSaveError(status: OSStatus)

    public var errorDescription: String? {
        switch self {
        case .invalidUTF8:
            return "The text could not be encoded or decoded as UTF-8."
        case .invalidBase64:
            return "The payload is not valid Base64."
        case .payloadCorrupted:
            return "The encrypted payload is corrupted or missing authentication tag."
        case .keychainReadError(let status):
            return "Keychain read operation failed with status code \(status)."
        case .keychainSaveError(let status):
            return "Keychain save operation failed with status code \(status)."
        }
    }
}

/// Thread-safe local MasterKeyVault actor providing AES-256-GCM encryption for stored secrets.
public actor MasterKeyVault: MasterKeyVaultProtocol {
    
    private let logger = Logger(subsystem: "com.kuma.app", category: "MasterKeyVault")
    private let keychainAccount = "com.kuma.masterkey"
    private let keychainService = "com.kuma.app"
    private let dbManager: DatabaseManager
    
    private var cachedKey: SymmetricKey?

    public init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
    }

    public func getOrCreateMasterKey() async throws -> SymmetricKey {
        if let key = cachedKey {
            return key
        }

        if let existingKey = try loadKeyFromKeychain() {
            cachedKey = existingKey
            return existingKey
        }

        // Generate new key & salt
        let newKey = SymmetricKey(size: .bits256)
        let rawKeyData = newKey.withUnsafeBytes { Data($0) }
        
        var saltBytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, saltBytes.count, &saltBytes)
        let saltData = Data(saltBytes)
        
        let checkHash = SHA256.hash(data: rawKeyData + saltData)
        let checkHashString = checkHash.compactMap { String(format: "%02x", $0) }.joined()

        try saveKeyToKeychain(rawKeyData)

        let saltBase64 = saltData.base64EncodedString()
        let record = MasterKeyRecord(
            id: "master_key",
            salt_base64: saltBase64,
            key_check_hash: checkHashString,
            created_at: Date(),
            updated_at: Date()
        )

        try await dbManager.dbWriter.write { db in
            try record.save(db)
        }

        cachedKey = newKey

        logger.info("Successfully initialized new 256-bit AES Master Key in Keychain and Database.")
        return newKey
    }

    public func encrypt(plainText: String) async throws -> (cipherTextBase64: String, nonceBase64: String) {
        let key = try await getOrCreateMasterKey()
        guard let data = plainText.data(using: .utf8) else {
            throw MasterKeyVaultError.invalidUTF8
        }
        
        let sealedBox = try AES.GCM.seal(data, using: key)
        let combinedData = sealedBox.ciphertext + sealedBox.tag
        
        let nonceData = Data(sealedBox.nonce)
        return (combinedData.base64EncodedString(), nonceData.base64EncodedString())
    }

    public func decrypt(cipherTextBase64: String, nonceBase64: String) async throws -> String {
        let key = try await getOrCreateMasterKey()
        
        guard let combinedData = Data(base64Encoded: cipherTextBase64),
              let nonceData = Data(base64Encoded: nonceBase64) else {
            throw MasterKeyVaultError.invalidBase64
        }
        
        guard combinedData.count >= 16 else {
            throw MasterKeyVaultError.payloadCorrupted
        }

        let nonce = try AES.GCM.Nonce(data: nonceData)
        let tagIndex = combinedData.count - 16
        let cipherText = combinedData.prefix(tagIndex)
        let tag = combinedData.suffix(16)

        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: cipherText, tag: tag)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        guard let resultString = String(data: decryptedData, encoding: .utf8) else {
            throw MasterKeyVaultError.invalidUTF8
        }
        return resultString
    }

    // MARK: - Keychain Helpers

    private func loadKeyFromKeychain() throws -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess, let data = item as? Data else {
            throw MasterKeyVaultError.keychainReadError(status: status)
        }
        return SymmetricKey(data: data)
    }

    private func saveKeyToKeychain(_ keyData: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw MasterKeyVaultError.keychainSaveError(status: status)
        }
    }
}
