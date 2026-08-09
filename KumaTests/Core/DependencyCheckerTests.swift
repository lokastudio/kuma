import XCTest
@testable import Kuma

final class DependencyCheckerTests: XCTestCase {
    
    func testCheckStandardSystemCommands() async {
        // Standard macOS commands that always exist on Unix
        let lsInstalled = await DependencyChecker.isCommandInstalled("ls")
        XCTAssertTrue(lsInstalled, "/bin/ls or /usr/bin/ls must be detected")
        
        let bogusInstalled = await DependencyChecker.isCommandInstalled("non_existent_command_12345")
        XCTAssertFalse(bogusInstalled)
    }
    
    func testCheckAllReturnsStatus() async {
        let status = await DependencyChecker.checkAll()
        // Status should execute without crashing
        XCTAssertNotNil(status)
    }
}
