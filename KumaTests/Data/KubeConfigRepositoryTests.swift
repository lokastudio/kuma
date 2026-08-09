import XCTest
import GRDB
@testable import Kuma

final class KubeConfigRepositoryTests: XCTestCase {
    var dbQueue: DatabaseQueue!
    var repository: KubeConfigRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        dbQueue = try DatabaseManager(inMemory: true).dbQueue
        repository = KubeConfigRepository(dbQueue: dbQueue)
    }
    
    override func tearDownWithError() throws {
        dbQueue = nil
        repository = nil
        try super.tearDownWithError()
    }
    
    func testInsertFetchAndUpdateKubeConfig() async throws {
        let id = UUID()
        let now = Date()
        let kubeConfig = KubeConfig(
            id: id,
            name: "Production Cluster",
            configContent: "apiVersion: v1\nkind: Config",
            createdAt: now,
            updatedAt: now
        )
        
        try await repository.insert(kubeConfig)
        
        var fetched = try await repository.fetch(id: id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.name, "Production Cluster")
        XCTAssertEqual(fetched?.configContent, "apiVersion: v1\nkind: Config")
        
        fetched?.name = "Staging Cluster"
        if let updatedConfig = fetched {
            try await repository.update(updatedConfig)
        }
        
        let reFetched = try await repository.fetch(id: id)
        XCTAssertEqual(reFetched?.name, "Staging Cluster")
        
        try await repository.delete(id: id)
        let deleted = try await repository.fetch(id: id)
        XCTAssertNil(deleted)
    }
}
