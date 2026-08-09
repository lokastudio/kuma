import XCTest
import GRDB
@testable import Kuma

final class ServiceRepositoryTests: XCTestCase {
    var dbQueue: DatabaseQueue!
    var repository: ServiceRepository!
    var workspaceRepository: WorkspaceRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        dbQueue = try DatabaseManager(inMemory: true).dbQueue
        repository = ServiceRepository(dbQueue: dbQueue)
        workspaceRepository = WorkspaceRepository(dbQueue: dbQueue)
    }
    
    override func tearDownWithError() throws {
        dbQueue = nil
        repository = nil
        workspaceRepository = nil
        try super.tearDownWithError()
    }
    
    func testInsertAndFetchService() async throws {
        let serviceID = UUID()
        let now = Date()
        
        let service = Service(
            id: serviceID,
            name: "Test Auth API",
            description: "Handles user login",
            activeProviderID: nil,
            workspaceID: nil,
            isDisabled: false,
            createdAt: now,
            updatedAt: now
        )
        
        try await repository.insert(service)
        
        let fetched = try await repository.fetch(id: serviceID)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.name, "Test Auth API")
        XCTAssertNil(fetched?.workspaceID)
        XCTAssertFalse(fetched!.isDisabled)
    }
    
    func testFetchAllForWorkspace() async throws {
        let now = Date()
        
        let ws1 = UUID()
        let ws2 = UUID()
        
        try await workspaceRepository.insert(Workspace(id: ws1, name: "WS 1", imagePath: nil, createdAt: now, updatedAt: now))
        try await workspaceRepository.insert(Workspace(id: ws2, name: "WS 2", imagePath: nil, createdAt: now, updatedAt: now))
        
        let s1 = Service(id: UUID(), name: "Service 1", description: nil, activeProviderID: nil, workspaceID: ws1, isDisabled: false, createdAt: now, updatedAt: now)
        let s2 = Service(id: UUID(), name: "Service 2", description: nil, activeProviderID: nil, workspaceID: ws1, isDisabled: false, createdAt: now, updatedAt: now)
        let s3 = Service(id: UUID(), name: "Service 3", description: nil, activeProviderID: nil, workspaceID: ws2, isDisabled: false, createdAt: now, updatedAt: now)
        
        try await repository.insert(s1)
        try await repository.insert(s2)
        try await repository.insert(s3)
        
        let ws1Services = try await repository.fetchAll(forWorkspace: ws1)
        XCTAssertEqual(ws1Services.count, 2)
        
        let ws2Services = try await repository.fetchAll(forWorkspace: ws2)
        XCTAssertEqual(ws2Services.count, 1)
        XCTAssertEqual(ws2Services.first?.name, "Service 3")
    }
    
    func testUpdateAndDeleteService() async throws {
        let serviceID = UUID()
        let now = Date()
        
        var service = Service(
            id: serviceID,
            name: "Original Name",
            description: nil,
            activeProviderID: nil,
            workspaceID: nil,
            isDisabled: false,
            createdAt: now,
            updatedAt: now
        )
        
        try await repository.insert(service)
        
        service.name = "Renamed Service"
        try await repository.update(service)
        
        let updated = try await repository.fetch(id: serviceID)
        XCTAssertEqual(updated?.name, "Renamed Service")
        
        try await repository.delete(id: serviceID)
        let deleted = try await repository.fetch(id: serviceID)
        XCTAssertNil(deleted)
    }
}
