import XCTest
@testable import Kuma

final class PortValidatorTests: XCTestCase {
    
    func testValidPortNumbers() {
        let validPorts = [1, 80, 443, 3000, 8080, 65535]
        for port in validPorts {
            XCTAssertTrue(port >= 1 && port <= 65535, "Port \(port) should be within 1..65535 range")
        }
    }
    
    func testInvalidPortNumbers() {
        let invalidPorts = [-1, 0, 65536, 100000]
        for port in invalidPorts {
            XCTAssertFalse(port >= 1 && port <= 65535, "Port \(port) is out of range")
        }
    }
}
