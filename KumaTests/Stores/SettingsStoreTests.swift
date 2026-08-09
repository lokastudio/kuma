import XCTest
@testable import Kuma

final class SettingsStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: SettingsStore.appearanceModeKey)
        UserDefaults.standard.removeObject(forKey: SettingsStore.launchAtLoginKey)
    }
    
    func testAppearanceModeDefaultAndMutation() {
        XCTAssertEqual(SettingsStore.appearanceMode, .system)
        
        UserDefaults.standard.set(AppearanceMode.dark.rawValue, forKey: SettingsStore.appearanceModeKey)
        XCTAssertEqual(SettingsStore.appearanceMode, .dark)
        
        UserDefaults.standard.set(AppearanceMode.light.rawValue, forKey: SettingsStore.appearanceModeKey)
        XCTAssertEqual(SettingsStore.appearanceMode, .light)
    }
    
    func testDefaultShellEnum() {
        XCTAssertEqual(DefaultShell.allCases.count, 3)
        XCTAssertEqual(DefaultShell.zsh.rawValue, "/bin/zsh")
        XCTAssertEqual(DefaultShell.bash.rawValue, "/bin/bash")
        XCTAssertEqual(DefaultShell.sh.rawValue, "/bin/sh")
    }
}
