//
//  PortConflictResolverTests.swift
//  KumaTests
//
//  Created for Task 4.7 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import XCTest

final class PortConflictResolverTests: XCTestCase {
    var resolver: PortConflictResolver!

    override func setUp() async throws {
        try await super.setUp()
        resolver = PortConflictResolver()
    }

    override func tearDown() async throws {
        resolver = nil
        try await super.tearDown()
    }

    func testPortConflictInfoCopywriting() {
        let info = PortConflictInfo(
            port: 5432,
            pid: 1234,
            processName: "postgres",
            user: "postgresUser"
        )

        XCTAssertEqual(info.port, 5432)
        XCTAssertEqual(info.pid, 1234)
        XCTAssertEqual(info.processName, "postgres")
        XCTAssertEqual(info.uiTitle, "Port 5432 is Already in Use")
        XCTAssertEqual(info.uiSubText, "Occupied by PID 1234 (postgres). Click to auto-free or resolve.")
    }

    func testCheckPortAvailabilityForUnboundPort() async {
        // High ephemeral port likely to be free during unit test execution
        let freePort = 59123
        let isAvailable = await resolver.checkPortAvailability(port: freePort)
        XCTAssertTrue(isAvailable, "Port \(freePort) should be reported as available")
    }

    func testSuggestAvailablePortProgression() async {
        let basePort = 49152
        let suggestedPort = await resolver.suggestAvailablePort(startingFrom: basePort)
        XCTAssertGreaterThanOrEqual(suggestedPort, basePort)
        
        let isAvailable = await resolver.checkPortAvailability(port: suggestedPort)
        XCTAssertTrue(isAvailable, "Suggested port \(suggestedPort) must be available")
    }

    func testRefuseSystemPIDKill() async {
        let systemConflict = PortConflictInfo(
            port: 80,
            pid: 1,
            processName: "launchd"
        )

        let success = await resolver.killProcessOccupyingPort(systemConflict, force: false)
        XCTAssertFalse(success, "Resolver must refuse to terminate PID 1")
    }
}
