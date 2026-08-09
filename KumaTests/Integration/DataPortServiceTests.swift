import XCTest
import GRDB
@testable import Kuma

@MainActor
final class DataPortServiceTests: XCTestCase {
    var dbQueue: DatabaseQueue!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        dbQueue = try DatabaseManager(inMemory: true).dbQueue
    }
    
    override func tearDownWithError() throws {
        dbQueue = nil
        try super.tearDownWithError()
    }
    
    func testExportAndImportRoundtrip() async throws {
        let wsID = UUID()
        let svcID = UUID()
        let provID = UUID()
        let now = Date()
        
        try await dbQueue.write { db in
            try Workspace(id: wsID, name: "Export WS", imagePath: nil, createdAt: now, updatedAt: now).insert(db)
            try Service(id: svcID, name: "Export Svc", description: nil, activeProviderID: provID, workspaceID: wsID, isDisabled: false, createdAt: now, updatedAt: now).insert(db)
            try Provider(id: provID, serviceID: svcID, type: .shell, label: "Export Prov", createdAt: now, updatedAt: now).insert(db)
            try PortMapping(id: UUID(), providerID: provID, localPort: 9000, remotePort: 9000).insert(db)
        }
        
        let exportedData = try await DataPortService.exportAll(dbQueue: dbQueue)
        XCTAssertFalse(exportedData.isEmpty)
        
        // Target a second fresh clean in-memory database
        let secondDbQueue = try DatabaseManager(inMemory: true).dbQueue
        
        // Clear default migration-created workspace in secondDbQueue before import
        try await DataPortService.resetAll(dbQueue: secondDbQueue)
        
        try await DataPortService.importAll(from: exportedData, dbQueue: secondDbQueue)
        
        let (exportedWs, svc, prov) = try await secondDbQueue.read { db in
            (
                try Workspace.fetchOne(db, key: wsID),
                try Service.fetchOne(db, key: svcID),
                try Provider.fetchOne(db, key: provID)
            )
        }
        
        XCTAssertNotNil(exportedWs)
        XCTAssertEqual(exportedWs?.name, "Export WS")
        
        XCTAssertNotNil(svc)
        XCTAssertEqual(svc?.name, "Export Svc")
        
        XCTAssertNotNil(prov)
        XCTAssertEqual(prov?.label, "Export Prov")
    }
    
    func testFutureVersionRejection() async throws {
        let futureJSON = """
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
            try await DataPortService.importAll(from: futureJSON, dbQueue: dbQueue)
            XCTFail("Should throw unsupportedFutureVersion error")
        } catch let error as DataPortService.DataPortError {
            if case .unsupportedFutureVersion(let backupVer, let currentVer) = error {
                XCTAssertEqual(backupVer, 999)
                XCTAssertEqual(currentVer, DataPortService.currentVersion)
            } else {
                XCTFail("Unexpected DataPortError: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
