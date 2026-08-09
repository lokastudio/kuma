//
//  ProcessRegistryTests.swift
//  KumaTests
//
//  Created by Antigravity on 2026-08-09.
//

import XCTest
@testable import Kuma

final class ProcessRegistryTests: XCTestCase {

    func testRegisterAndQueryProcesses() async {
        let registry = ProcessRegistry()
        let serviceId = UUID()
        let providerId = UUID()

        let handleId = await registry.register(
            pid: 1234,
            pgid: 1234,
            serviceId: serviceId,
            providerId: providerId,
            command: "sleep 10"
        )

        let active = await registry.activeProcesses()
        XCTAssertEqual(active.count, 1)
        XCTAssertEqual(active.first?.id, handleId)
        XCTAssertEqual(active.first?.pid, 1234)

        let forService = await registry.activeProcesses(forService: serviceId)
        XCTAssertEqual(forService.count, 1)

        await registry.unregister(handleId: handleId)
        let activeAfter = await registry.activeProcesses()
        XCTAssertEqual(activeAfter.count, 0)
    }

    func testGracefulProcessGroupTermination() async throws {
        let registry = ProcessRegistry()
        let serviceId = UUID()
        let providerId = UUID()

        // Spawn a background process group using `sleep 60`
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sleep")
        process.arguments = ["60"]

        // Put child in its own process group
        #if os(macOS)
        let pipe = Pipe()
        process.standardOutput = pipe
        #endif

        try process.run()

        let pid = process.processIdentifier
        let pgid = getpgid(pid)

        let handleId = await registry.register(
            pid: pid,
            pgid: pgid > 0 ? pgid : pid,
            serviceId: serviceId,
            providerId: providerId,
            command: "sleep 60"
        )

        XCTAssertTrue(process.isRunning)

        // Execute termination sequence
        await registry.terminateProcess(handleId: handleId)

        // Wait brief moment for process exit
        try await Task.sleep(nanoseconds: 200_000_000)

        let activeAfter = await registry.activeProcesses()
        XCTAssertEqual(activeAfter.count, 0)
        XCTAssertFalse(process.isRunning)
    }
}
