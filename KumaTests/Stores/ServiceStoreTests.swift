import XCTest
import GRDB
@testable import Kuma

@MainActor
final class ServiceStoreTests: XCTestCase {
    var dbQueue: DatabaseQueue!
    var serviceRepo: ServiceRepository!
    var providerRepo: ProviderRepository!
    var workspaceRepo: WorkspaceRepository!
    var store: ServiceStore!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        dbQueue = try DatabaseManager(inMemory: true).dbQueue
        serviceRepo = ServiceRepository(dbQueue: dbQueue)
        providerRepo = ProviderRepository(dbQueue: dbQueue)
        workspaceRepo = WorkspaceRepository(dbQueue: dbQueue)
        store = ServiceStore(repository: serviceRepo, providerRepository: providerRepo)
    }
    
    override func tearDownWithError() throws {
        dbQueue = nil
        serviceRepo = nil
        providerRepo = nil
        workspaceRepo = nil
        store = nil
        try super.tearDownWithError()
    }
    
    func testLoadServicesForWorkspace() async throws {
        let wsID = UUID()
        let now = Date()
        
        try await workspaceRepo.insert(Workspace(id: wsID, name: "Test Space", imagePath: nil, createdAt: now, updatedAt: now))
        
        let s1 = Service(id: UUID(), name: "Web App", description: nil, activeProviderID: nil, workspaceID: wsID, isDisabled: false, createdAt: now, updatedAt: now)
        try await serviceRepo.insert(s1)
        
        await store.loadServices(forWorkspace: wsID)
        XCTAssertEqual(store.services.count, 1)
        XCTAssertEqual(store.services.first?.name, "Web App")
        XCTAssertFalse(store.hasRunningServices)
    }
    
    func testServiceStateTracking() {
        let serviceID = UUID()
        XCTAssertEqual(store.serviceStates[serviceID], nil)
        
        store.serviceStates[serviceID] = .running
        XCTAssertEqual(store.serviceStates[serviceID], .running)
        XCTAssertTrue(store.hasRunningServices)
        
        store.serviceStates[serviceID] = .stopped
        XCTAssertFalse(store.hasRunningServices)
    }
}
