import XCTest
import GRDB
@testable import Kuma

final class V1SchemaMigrationTests: XCTestCase {
    
    func testV1SchemaMigrationInitialization() throws {
        let dbManager = try DatabaseManager.makeInMemory()
        
        try dbManager.dbWriter.read { db in
            // Verify all 9 normalized tables exist
            XCTAssertTrue(try db.tableExists("workspaces"), "Table 'workspaces' should exist")
            XCTAssertTrue(try db.tableExists("service_groups"), "Table 'service_groups' should exist")
            XCTAssertTrue(try db.tableExists("services"), "Table 'services' should exist")
            XCTAssertTrue(try db.tableExists("providers"), "Table 'providers' should exist")
            XCTAssertTrue(try db.tableExists("port_mappings"), "Table 'port_mappings' should exist")
            XCTAssertTrue(try db.tableExists("vault_secrets"), "Table 'vault_secrets' should exist")
            XCTAssertTrue(try db.tableExists("kubeconfigs"), "Table 'kubeconfigs' should exist")
            XCTAssertTrue(try db.tableExists("master_key_vault"), "Table 'master_key_vault' should exist")
            XCTAssertTrue(try db.tableExists("settings"), "Table 'settings' should exist")
            
            // Verify expected columns in key tables
            let workspaceColumns = try db.columns(in: "workspaces").map(\.name)
            XCTAssertTrue(workspaceColumns.contains("id"))
            XCTAssertTrue(workspaceColumns.contains("name"))
            XCTAssertTrue(workspaceColumns.contains("image_path"))
            XCTAssertTrue(workspaceColumns.contains("sort_order"))
            XCTAssertTrue(workspaceColumns.contains("created_at"))
            XCTAssertTrue(workspaceColumns.contains("updated_at"))
            
            let serviceColumns = try db.columns(in: "services").map(\.name)
            XCTAssertTrue(serviceColumns.contains("workspace_id"))
            XCTAssertTrue(serviceColumns.contains("group_id"))
            XCTAssertTrue(serviceColumns.contains("active_provider_id"))
            XCTAssertTrue(serviceColumns.contains("last_status"))
            XCTAssertTrue(serviceColumns.contains("is_disabled"))
            XCTAssertTrue(serviceColumns.contains("is_favorite"))
            
            let providerColumns = try db.columns(in: "providers").map(\.name)
            XCTAssertTrue(providerColumns.contains("service_id"))
            XCTAssertTrue(providerColumns.contains("provider_type"))
            XCTAssertTrue(providerColumns.contains("config_json"))
            XCTAssertTrue(providerColumns.contains("kube_config_id"))
            
            let vaultSecretColumns = try db.columns(in: "vault_secrets").map(\.name)
            XCTAssertTrue(vaultSecretColumns.contains("provider_id"))
            XCTAssertTrue(vaultSecretColumns.contains("secret_type"))
            XCTAssertTrue(vaultSecretColumns.contains("ciphertext_base64"))
            XCTAssertTrue(vaultSecretColumns.contains("nonce_base64"))
            
            let kubeConfigColumns = try db.columns(in: "kubeconfigs").map(\.name)
            XCTAssertTrue(kubeConfigColumns.contains("bookmark_data"))
            XCTAssertTrue(kubeConfigColumns.contains("config_content_encrypted"))
        }
    }
}
