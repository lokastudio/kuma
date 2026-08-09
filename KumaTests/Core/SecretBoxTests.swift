import XCTest
@testable import Kuma

final class SecretBoxTests: XCTestCase {
    
    func testEncryptAndDecryptRoundtrip() {
        let originalText = "kuma_secret_api_key_2026_xyz"
        let encryptedData = SecretBox.shared.encrypt(originalText)
        
        XCTAssertNotNil(encryptedData)
        XCTAssertNotEqual(encryptedData, originalText.data(using: .utf8))
        
        let decrypted = SecretBox.shared.decrypt(encryptedData)
        XCTAssertEqual(decrypted, originalText)
    }
    
    func testNilAndEmptyDecryptionHandling() {
        XCTAssertNil(SecretBox.shared.decrypt(nil))
        XCTAssertNil(SecretBox.shared.encrypt(nil))
        
        let emptyEncrypted = SecretBox.shared.encrypt("")
        XCTAssertEqual(SecretBox.shared.decrypt(emptyEncrypted), "")
    }
    
    func testCorruptedCiphertextReturnsNil() {
        let corruptData = Data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        let result = SecretBox.shared.decrypt(corruptData)
        XCTAssertNil(result, "Decryption of invalid AES-GCM payload should return nil safely without crash")
    }
}
