import XCTest
import GRDB
@testable import Kuma

@MainActor
final class KubeConfigStoreTests: XCTestCase {
    var dbQueue: DatabaseQueue!
    var repository: KubeConfigRepository!
    var store: KubeConfigStore!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        dbQueue = try DatabaseManager(inMemory: true).dbQueue
        repository = KubeConfigRepository(dbQueue: dbQueue)
        store = KubeConfigStore(repository: repository)
    }
    
    override func tearDownWithError() throws {
        dbQueue = nil
        repository = nil
        store = nil
        try super.tearDownWithError()
    }
    
    func testLoadAndAddKubeConfig() async throws {
        await store.loadConfigs()
        XCTAssertEqual(store.kubeConfigs.count, 0)
        
        let created = try await store.addConfig(name: "Staging Cluster", content: "apiVersion: v1")
        XCTAssertEqual(created.name, "Staging Cluster")
        XCTAssertEqual(store.kubeConfigs.count, 1)
    }
    
    func testAddConfigEmptyNameValidation() async throws {
        do {
            _ = try await store.addConfig(name: "  ", content: "yaml")
            XCTFail("Should fail with empty name")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains("Name cannot be empty"))
        }
    }
}
