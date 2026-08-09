import XCTest
import GRDB
@testable import Kuma

final class MigrationTests: XCTestCase {
    
    /// Test clean migration execution from scratch on an in-memory DatabaseQueue
    func testFreshDatabaseMigration() throws {
        var config = Configuration()
        config.prepareDatabase { db in
            try? db.execute(sql: "PRAGMA foreign_keys = ON")
        }
        let dbQueue = try DatabaseQueue(configuration: config)
        
        var migrator = DatabaseMigrator()
        AppMigrations.register(in: &migrator)
        
        do {
            try migrator.migrate(dbQueue)
            try SeedService.seedInitialData(dbQueue: dbQueue)
        } catch {
            print("MIGRATION_ERROR: \(error)")
            XCTFail("Migration failed with error: \(error)")
        }
        
        // Verify core tables exist
        try dbQueue.read { db in
            XCTAssertTrue(try db.tableExists("service"))
            XCTAssertTrue(try db.tableExists("provider"))
            XCTAssertTrue(try db.tableExists("port_mapping"))
            XCTAssertTrue(try db.tableExists("workspace"))
            XCTAssertTrue(try db.tableExists("kube_config"))
            
            let providerColumns = try db.columns(in: "provider").map(\.name)
            let kubeConfigColumns = try db.columns(in: "kube_config").map(\.name)
            
            XCTAssertTrue(providerColumns.contains("monitorProcessName"))
            XCTAssertTrue(providerColumns.contains("monitorInterval"))
            XCTAssertTrue(providerColumns.contains("sshPasswordEncrypted"))
            XCTAssertTrue(providerColumns.contains("ngrokAuthTokenEncrypted"))
            XCTAssertTrue(kubeConfigColumns.contains("configContentEncrypted"))
            
            let workspaceCount = try Workspace.fetchCount(db)
            XCTAssertEqual(workspaceCount, 1)
        }
    }
    
    /// Test migration & data insertion with AppMigrations
    func testSequentialMigrationWithExistingData() throws {
        var config = Configuration()
        config.prepareDatabase { db in
            try? db.execute(sql: "PRAGMA foreign_keys = OFF")
        }
        let dbQueue = try DatabaseQueue(configuration: config)
        
        var migrator = DatabaseMigrator()
        AppMigrations.register(in: &migrator)
        try migrator.migrate(dbQueue)
        
        let srcUUIDStr = "11111111-1111-1111-1111-111111111111"
        let provUUIDStr = "22222222-2222-2222-2222-222222222222"
        let now = Date()
        
        try dbQueue.write { db in
            try db.execute(
                sql: "INSERT INTO service (id, name, createdAt, updatedAt) VALUES (?, ?, ?, ?)",
                arguments: [srcUUIDStr, "Test Web Service", now, now]
            )
            try db.execute(
                sql: "INSERT INTO provider (id, serviceID, label, type, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?)",
                arguments: [provUUIDStr, srcUUIDStr, "K8s Provider", "kube_port_forward", now, now]
            )
        }
        
        try dbQueue.read { db in
            XCTAssertTrue(try db.tableExists("service"))
            
            let serviceRow = try Row.fetchOne(db, sql: "SELECT * FROM service WHERE id = ?", arguments: [srcUUIDStr])
            XCTAssertNotNil(serviceRow, "Service record should exist in 'service' table")
            if let serviceRow {
                XCTAssertEqual(serviceRow["name"], "Test Web Service")
            }
            
            let providerRow = try Row.fetchOne(db, sql: "SELECT * FROM provider WHERE id = ?", arguments: [provUUIDStr])
            XCTAssertNotNil(providerRow, "Provider record should exist in 'provider' table")
            if let providerRow {
                XCTAssertEqual(providerRow["serviceID"], srcUUIDStr)
            }
        }
    }
    
    /// Test DataPortService version compatibility check
    func testDataPortFutureVersionRejection() async throws {
        let dbQueue = try DatabaseManager(inMemory: true).dbQueue
        
        // JSON backup payload with version 999
        let futureBackupJSON = """
        {
            "version": 999,
            "exportedAt": "2026-08-04T12:00:00Z",
            "workspaces": [],
            "services": [],
            "providers": [],
            "portMappings": [],
            "kubeConfigs": []
        }
        """.data(using: .utf8)!
        
        do {
            try await DataPortService.importAll(from: futureBackupJSON, dbQueue: dbQueue)
            XCTFail("Expected importAll to throw unsupportedFutureVersion error for version 999")
        } catch let error as DataPortService.DataPortError {
            if case .unsupportedFutureVersion(let backupVer, let currentVer) = error {
                XCTAssertEqual(backupVer, 999)
                XCTAssertEqual(currentVer, DataPortService.currentVersion)
            } else {
                XCTFail("Unexpected DataPortError: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
