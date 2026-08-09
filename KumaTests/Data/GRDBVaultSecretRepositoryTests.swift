//
//  GRDBVaultSecretRepositoryTests.swift
//  KumaTests
//
//  Created for Task 3.6 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import XCTest
import GRDB
@testable import Kuma

final class GRDBVaultSecretRepositoryTests: XCTestCase {
    
    private var testQueue: DatabaseQueue!
    private var vault: MasterKeyVault!
    private var repository: GRDBVaultSecretRepository!
    private var providerId: UUID!

    override func setUpWithError() throws {
        try super.setUpWithError()
        testQueue = try DatabaseQueue()
        var migrator = DatabaseMigrator()
        V1SchemaMigration.register(on: &migrator)
        try migrator.migrate(testQueue)
        
        let dbManager = DatabaseManager(dbWriter: testQueue)
        vault = MasterKeyVault(dbManager: dbManager)
        repository = GRDBVaultSecretRepository(dbManager: dbManager, masterKeyVault: vault)
        
        let workspaceId = UUID()
        let serviceId = UUID()
        providerId = UUID()

        try testQueue.write { db in
            let ws = WorkspaceRecord(id: workspaceId.uuidString, name: "Test WS", image_path: nil, sort_order: 0, created_at: Date(), updated_at: Date())
            try ws.save(db)
            
            let svc = ServiceRecord(id: serviceId.uuidString, workspace_id: workspaceId.uuidString, group_id: nil, name: "Test Svc", description: nil, is_disabled: false, is_favorite: false, active_provider_id: nil, last_status: "stopped", last_active_port: nil, sort_order: 0, created_at: Date(), updated_at: Date())
            try svc.save(db)
            
            let prov = ProviderRecord(id: providerId.uuidString, service_id: serviceId.uuidString, label: "SSH Prov", provider_type: "ssh", config_json: "{}", kube_config_id: nil, created_at: Date(), updated_at: Date())
            try prov.save(db)
        }
    }

    override func tearDownWithError() throws {
        repository = nil
        vault = nil
        testQueue = nil
        try super.tearDownWithError()
    }

    func testSaveFetchAndDecryptSecret() async throws {
        let initialSecret = VaultSecret(
            providerId: providerId,
            secretType: .sshPassword,
            ciphertextBase64: "",
            nonceBase64: ""
        )
        let rawSecretString = "mypassword123"

        let savedSecret = try await repository.saveSecret(initialSecret, plainTextValue: rawSecretString)
        XCTAssertFalse(savedSecret.ciphertextBase64.isEmpty)
        XCTAssertFalse(savedSecret.nonceBase64.isEmpty)

        let fetchedSecret = try await repository.fetchSecret(id: savedSecret.id)
        XCTAssertNotNil(fetchedSecret)
        XCTAssertEqual(fetchedSecret?.id, savedSecret.id)

        let decryptedValue = try await repository.decryptValue(for: fetchedSecret!)
        XCTAssertEqual(decryptedValue, rawSecretString)

        let providerSecrets = try await repository.fetchSecrets(forProvider: providerId)
        XCTAssertEqual(providerSecrets.count, 1)
        XCTAssertEqual(providerSecrets.first?.id, savedSecret.id)

        try await repository.deleteSecret(id: savedSecret.id)
        let deletedSecret = try await repository.fetchSecret(id: savedSecret.id)
        XCTAssertNil(deletedSecret)
    }
}
