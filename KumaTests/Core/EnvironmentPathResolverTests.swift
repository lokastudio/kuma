//
//  EnvironmentPathResolverTests.swift
//  KumaTests
//
//  Created by Antigravity on 2026-08-09.
//

import XCTest
@testable import Kuma

final class EnvironmentPathResolverTests: XCTestCase {

    func testResolvePath_ReturnsNonEmptyPath() async {
        let resolver = EnvironmentPathResolver()
        let path = await resolver.resolvePath()
        
        XCTAssertFalse(path.isEmpty, "Resolved PATH should not be empty")
        XCTAssertTrue(path.contains("/usr/bin") || path.contains("/bin"), "Resolved PATH should contain standard macOS directories")
    }

    func testResolveExecutablePath_FindsCommonSystemBinary() async {
        let resolver = EnvironmentPathResolver()
        
        let lsPath = await resolver.resolveExecutablePath(for: "ls")
        XCTAssertNotNil(lsPath, "Should find system 'ls' binary")
        if let lsPath = lsPath {
            XCTAssertTrue(lsPath.hasSuffix("/ls"), "Binary path should end with /ls")
        }

        let zshPath = await resolver.resolveExecutablePath(for: "zsh")
        XCTAssertNotNil(zshPath, "Should find system 'zsh' binary")
    }

    func testResolveExecutablePath_HandlesAbsolutePath() async {
        let resolver = EnvironmentPathResolver()
        
        let validPath = await resolver.resolveExecutablePath(for: "/bin/sh")
        XCTAssertEqual(validPath, "/bin/sh")

        let invalidPath = await resolver.resolveExecutablePath(for: "/bin/non_existent_binary_xyz_999")
        XCTAssertNil(invalidPath)
    }

    func testResolveExecutablePath_HandlesTildePath() async {
        let resolver = EnvironmentPathResolver()
        
        // Pass a tilde path to an executable file (e.g. ~/.zshrc or binary if exists)
        let tildeBinary = "~/non_existent_binary_xyz_123"
        let result = await resolver.resolveExecutablePath(for: tildeBinary)
        XCTAssertNil(result)
    }

    func testResolveExecutablePath_ReturnsNilForNonExistentBinary() async {
        let resolver = EnvironmentPathResolver()
        let result = await resolver.resolveExecutablePath(for: "definitely_not_a_real_binary_12345")
        XCTAssertNil(result)
    }

    func testCustomPathsPrecedence() async {
        let resolver = EnvironmentPathResolver()
        await resolver.setCustomPaths(["/custom/test/path"])
        
        let path = await resolver.resolvePath()
        XCTAssertTrue(path.hasPrefix("/custom/test/path"), "Custom path should take high precedence at beginning of PATH")
    }

    func testRefreshPath() async {
        let resolver = EnvironmentPathResolver()
        await resolver.setCustomPaths(["/temp/path"])
        
        var path = await resolver.resolvePath()
        XCTAssertTrue(path.hasPrefix("/temp/path"))
        
        // Refresh without custom paths by setting custom paths empty
        await resolver.setCustomPaths([])
        path = await resolver.refreshPath()
        XCTAssertFalse(path.hasPrefix("/temp/path"), "Refreshed path should clear stale custom paths cache")
    }
}
