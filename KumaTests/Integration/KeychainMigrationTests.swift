import XCTest
import GRDB
@testable import Kuma

final class KeychainMigrationTests: XCTestCase {
    
    func testSecretBoxEncryptionDecryption() throws {
        let plaintext = "super_secret_ssh_password_123!"
        
        // Test encryption
        let encryptedData = SecretBox.shared.encrypt(plaintext)
        XCTAssertNotNil(encryptedData)
        XCTAssertNotEqual(encryptedData, plaintext.data(using: .utf8))
        
        // Test decryption
        let decryptedText = SecretBox.shared.decrypt(encryptedData)
        XCTAssertEqual(decryptedText, plaintext)
    }
    
    func testProviderAndKubeConfigEncryptedRecordPersistence() throws {
        let dbQueue = try DatabaseManager(inMemory: true).dbQueue
        let serviceID = UUID()
        let providerID = UUID()
        let kubeConfigID = UUID()
        let now = Date()
        
        let rawYaml = "apiVersion: v1\nkind: Config\nclusters: []"
        let secretSshPassword = "my_private_ssh_password_99"
        let secretNgrokToken = "ngrok_token_abcdef123"
        
        try dbQueue.write { db in
            let service = Service(id: serviceID, name: "Encrypted DB Test Service", description: nil, isDisabled: false, createdAt: now, updatedAt: now)
            try service.insert(db)
            
            let provider = Provider(
                id: providerID,
                serviceID: serviceID,
                type: .shell,
                label: "Shell Provider",
                sshPassword: secretSshPassword,
                ngrokAuthToken: secretNgrokToken,
                createdAt: now,
                updatedAt: now
            )
            try provider.insert(db)
            
            let kubeConfig = KubeConfig(
                id: kubeConfigID,
                name: "Staging Cluster",
                configContent: rawYaml,
                createdAt: now,
                updatedAt: now
            )
            try kubeConfig.insert(db)
        }
        
        // 1. Verify in-memory hydration on read
        try dbQueue.read { db in
            let fetchedProvider = try Provider.fetchOne(db, key: providerID)
            XCTAssertNotNil(fetchedProvider)
            XCTAssertEqual(fetchedProvider?.sshPassword, secretSshPassword)
            XCTAssertEqual(fetchedProvider?.ngrokAuthToken, secretNgrokToken)
            
            let fetchedKubeConfig = try KubeConfig.fetchOne(db, key: kubeConfigID)
            XCTAssertNotNil(fetchedKubeConfig)
            XCTAssertEqual(fetchedKubeConfig?.configContent, rawYaml)
        }
        
        // 2. Verify raw SQLite table rows store AES-256 ciphertext Data (BLOB), not plaintext
        try dbQueue.read { db in
            let row = try Row.fetchOne(db, sql: "SELECT sshPasswordEncrypted, ngrokAuthTokenEncrypted FROM provider WHERE id = ?", arguments: [providerID])
            let encSshData: Data? = row?["sshPasswordEncrypted"]
            let encNgrokData: Data? = row?["ngrokAuthTokenEncrypted"]
            
            XCTAssertNotNil(encSshData)
            XCTAssertNotEqual(String(data: encSshData!, encoding: .utf8), secretSshPassword)
            XCTAssertEqual(SecretBox.shared.decrypt(encSshData), secretSshPassword)
            
            XCTAssertNotNil(encNgrokData)
            XCTAssertEqual(SecretBox.shared.decrypt(encNgrokData), secretNgrokToken)
            
            let kubeRow = try Row.fetchOne(db, sql: "SELECT configContentEncrypted FROM kube_config WHERE id = ?", arguments: [kubeConfigID])
            let encKubeData: Data? = kubeRow?["configContentEncrypted"]
            
            XCTAssertNotNil(encKubeData)
            XCTAssertEqual(SecretBox.shared.decrypt(encKubeData), rawYaml)
        }
    }
}
