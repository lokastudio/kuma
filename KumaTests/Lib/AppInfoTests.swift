import XCTest
@testable import Kuma

final class AppInfoTests: XCTestCase {
    
    func testAppInfoVersionNotEmpty() {
        XCTAssertFalse(AppInfo.version.isEmpty, "AppInfo.version should not be empty")
    }
    
    func testAppInfoBuildNotEmpty() {
        XCTAssertFalse(AppInfo.build.isEmpty, "AppInfo.build should not be empty")
    }
    
    func testAppInfoFormattedVersionContainsVersionAndBuild() {
        let formatted = AppInfo.formattedVersion
        XCTAssertTrue(formatted.contains("Version"), "Formatted version should contain 'Version'")
        XCTAssertTrue(formatted.contains(AppInfo.version), "Formatted version should contain current version")
        XCTAssertTrue(formatted.contains(AppInfo.build), "Formatted version should contain current build")
    }
    
    func testAppInfoBundleIdentifier() {
        let bundleID = AppInfo.bundleIdentifier
        XCTAssertFalse(bundleID.isEmpty, "Bundle identifier should not be empty")
    }
}
