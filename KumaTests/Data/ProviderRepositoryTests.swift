import XCTest
import GRDB
@testable import Kuma

final class ProviderRepositoryTests: XCTestCase {
    var dbQueue: DatabaseQueue!
    var providerRepo: ProviderRepository!
    var serviceRepo: ServiceRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        dbQueue = try DatabaseManager(inMemory: true).dbQueue
        providerRepo = ProviderRepository(dbQueue: dbQueue)
        serviceRepo = ServiceRepository(dbQueue: dbQueue)
    }
    
    override func tearDownWithError() throws {
        dbQueue = nil
        providerRepo = nil
        serviceRepo = nil
        try super.tearDownWithError()
    }
    
    func testInsertAndFetchProviderWithPortMappings() async throws {
        let serviceID = UUID()
        let providerID = UUID()
        let now = Date()
        
        let service = Service(id: serviceID, name: "Web Service", description: nil, activeProviderID: nil, workspaceID: nil, isDisabled: false, createdAt: now, updatedAt: now)
        try await serviceRepo.insert(service)
        
        let provider = Provider(
            id: providerID,
            serviceID: serviceID,
            type: .kubePortForward,
            label: "Staging Cluster",
            createdAt: now,
            updatedAt: now
        )
        try await providerRepo.insert(provider)
        
        let mappings = [
            PortMapping(id: UUID(), providerID: providerID, localPort: 8080, remotePort: 80),
            PortMapping(id: UUID(), providerID: providerID, localPort: 8443, remotePort: 443)
        ]
        try await providerRepo.replacePortMappings(forProvider: providerID, mappings)
        
        let fetchedProvider = try await providerRepo.fetch(id: providerID)
        XCTAssertNotNil(fetchedProvider)
        XCTAssertEqual(fetchedProvider?.type, .kubePortForward)
        
        let fetchedMappings = try await providerRepo.fetchPortMappings(forProvider: providerID)
        XCTAssertEqual(fetchedMappings.count, 2)
    }
    
    func testBatchFetchProvidersAndMappings() async throws {
        let serviceID1 = UUID()
        let serviceID2 = UUID()
        let providerID1 = UUID()
        let providerID2 = UUID()
        let now = Date()
        
        try await serviceRepo.insert(Service(id: serviceID1, name: "S1", description: nil, activeProviderID: nil, workspaceID: nil, isDisabled: false, createdAt: now, updatedAt: now))
        try await serviceRepo.insert(Service(id: serviceID2, name: "S2", description: nil, activeProviderID: nil, workspaceID: nil, isDisabled: false, createdAt: now, updatedAt: now))
        
        try await providerRepo.insert(Provider(id: providerID1, serviceID: serviceID1, type: .docker, label: "Docker Provider", createdAt: now, updatedAt: now))
        try await providerRepo.insert(Provider(id: providerID2, serviceID: serviceID2, type: .shell, label: "Shell Provider", createdAt: now, updatedAt: now))
        
        let providers = try await providerRepo.fetchAll(forServiceIDs: [serviceID1, serviceID2])
        XCTAssertEqual(providers.count, 2)
    }
}
