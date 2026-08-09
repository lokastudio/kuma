import XCTest
@testable import Kuma

final class ServiceTests: XCTestCase {
    
    func testServiceInitializationAndEquality() {
        let id = UUID()
        let workspaceID = UUID()
        let now = Date()
        
        let service1 = Service(
            id: id,
            name: "Backend Service",
            description: "API Gateway",
            activeProviderID: nil,
            workspaceID: workspaceID,
            isDisabled: false,
            createdAt: now,
            updatedAt: now
        )
        
        let service2 = Service(
            id: id,
            name: "Backend Service",
            description: "API Gateway",
            activeProviderID: nil,
            workspaceID: workspaceID,
            isDisabled: false,
            createdAt: now,
            updatedAt: now
        )
        
        XCTAssertEqual(service1, service2)
        XCTAssertEqual(service1.name, "Backend Service")
        XCTAssertEqual(service1.description, "API Gateway")
        XCTAssertFalse(service1.isDisabled)
    }
    
    func testServiceMutation() {
        let id = UUID()
        let now = Date()
        
        var service = Service(
            id: id,
            name: "Initial Name",
            description: nil,
            activeProviderID: nil,
            workspaceID: nil,
            isDisabled: false,
            createdAt: now,
            updatedAt: now
        )
        
        service.name = "Updated Name"
        service.isDisabled = true
        
        XCTAssertEqual(service.name, "Updated Name")
        XCTAssertTrue(service.isDisabled)
    }
}
