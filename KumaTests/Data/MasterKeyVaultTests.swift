//
//  MasterKeyVaultTests.swift
//  KumaTests
//
//  Created for Task 3.6 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import XCTest
import GRDB
@testable import Kuma

final class MasterKeyVaultTests: XCTestCase {
    
    private var testQueue: DatabaseQueue!
    private var vault: MasterKeyVault!

    override func setUpWithError() throws {
        try super.setUpWithError()
        testQueue = try DatabaseQueue()
        var migrator = DatabaseMigrator()
        V1SchemaMigration.register(on: &migrator)
        try migrator.migrate(testQueue)
        
        let dbManager = DatabaseManager(dbWriter: testQueue)
        vault = MasterKeyVault(dbManager: dbManager)
    }

    override func tearDownWithError() throws {
        vault = nil
        testQueue = nil
        try super.tearDownWithError()
    }

    func testMasterKeyDerivationAndEncryptionRoundtrip() async throws {
        let plainText = "super_secret_ssh_passphrase_2026"
        
        let (cipherTextBase64, nonceBase64) = try await vault.encrypt(plainText: plainText)
        XCTAssertFalse(cipherTextBase64.isEmpty)
        XCTAssertFalse(nonceBase64.isEmpty)
        XCTAssertNotEqual(cipherTextBase64, plainText)
        
        let decryptedText = try await vault.decrypt(cipherTextBase64: cipherTextBase64, nonceBase64: nonceBase64)
        XCTAssertEqual(decryptedText, plainText)
    }

    func testCorruptedPayloadThrowsError() async {
        do {
            _ = try await vault.decrypt(cipherTextBase64: "invalid_base64", nonceBase64: "invalid_base64")
            XCTFail("Expected error when decrypting invalid base64")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
