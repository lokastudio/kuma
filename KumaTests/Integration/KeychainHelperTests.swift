import XCTest
@testable import Kuma

final class KeychainHelperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        KeychainHelper.shared.deleteAll(prefix: "test.")
    }
    
    override func tearDown() {
        KeychainHelper.shared.deleteAll(prefix: "test.")
        super.tearDown()
    }
    
    func testKeychainSaveReadDelete() throws {
        let key = "test.provider.123.sshPassword"
        let secret = "super_secret_ssh_password_123"
        
        // Save
        try KeychainHelper.shared.save(key: key, secret: secret)
        
        // Read
        let fetched = KeychainHelper.shared.read(key: key)
        XCTAssertEqual(fetched, secret)
        
        // Update
        let updatedSecret = "new_secret_456"
        try KeychainHelper.shared.save(key: key, secret: updatedSecret)
        XCTAssertEqual(KeychainHelper.shared.read(key: key), updatedSecret)
        
        // Delete
        KeychainHelper.shared.delete(key: key)
        XCTAssertNil(KeychainHelper.shared.read(key: key))
    }
}
