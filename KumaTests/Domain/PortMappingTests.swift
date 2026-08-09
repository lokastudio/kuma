import XCTest
@testable import Kuma

final class PortMappingTests: XCTestCase {
    
    func testPortMappingInitialization() {
        let id = UUID()
        let providerID = UUID()
        
        let mapping = PortMapping(
            id: id,
            providerID: providerID,
            localPort: 8080,
            remotePort: 80
        )
        
        XCTAssertEqual(mapping.id, id)
        XCTAssertEqual(mapping.providerID, providerID)
        XCTAssertEqual(mapping.localPort, 8080)
        XCTAssertEqual(mapping.remotePort, 80)
    }
    
    func testPortMappingEquality() {
        let id = UUID()
        let providerID = UUID()
        
        let mapping1 = PortMapping(id: id, providerID: providerID, localPort: 3000, remotePort: 3000)
        let mapping2 = PortMapping(id: id, providerID: providerID, localPort: 3000, remotePort: 3000)
        let mapping3 = PortMapping(id: id, providerID: providerID, localPort: 3001, remotePort: 3000)
        
        XCTAssertEqual(mapping1, mapping2)
        XCTAssertNotEqual(mapping1, mapping3)
    }
}
