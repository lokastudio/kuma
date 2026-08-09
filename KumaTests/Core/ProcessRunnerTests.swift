//
//  ProcessRunnerTests.swift
//  KumaTests
//
//  Created by Antigravity on 2026-08-09.
//

import XCTest
@testable import Kuma

final class ProcessRunnerTests: XCTestCase {

    func testRunEchoCommandSuccess() async throws {
        let runner = ProcessRunner()
        let echoURL = URL(fileURLWithPath: "/bin/echo")

        let config = ProcessExecutionConfig(
            executableURL: echoURL,
            arguments: ["Hello", "Kuma", "Engine"]
        )

        let result = try await runner.run(config: config)

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout.trimmingCharacters(in: .whitespacesAndNewlines), "Hello Kuma Engine")
    }

    func testStreamOutputLines() async throws {
        let runner = ProcessRunner()
        let echoURL = URL(fileURLWithPath: "/bin/echo")

        let config = ProcessExecutionConfig(
            executableURL: echoURL,
            arguments: ["Line1\nLine2\nLine3"]
        )

        let (stream, task) = await runner.stream(config: config)

        var lines: [String] = []
        for await line in stream {
            lines.append(line)
        }

        let result = try await task.value
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(lines, ["Line1", "Line2", "Line3"])
    }

    func testExecutableNotFoundThrowsError() async {
        let runner = ProcessRunner()
        let invalidURL = URL(fileURLWithPath: "/usr/bin/non_existent_kuma_binary_12345")

        let config = ProcessExecutionConfig(executableURL: invalidURL)

        do {
            _ = try await runner.run(config: config)
            XCTFail("Expected ProcessRunnerError.executableNotFound, but succeeded")
        } catch let ProcessRunnerError.executableNotFound(path) {
            XCTAssertEqual(path, "/usr/bin/non_existent_kuma_binary_12345")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testNonZeroExitCodeThrowsExecutionTerminated() async {
        let runner = ProcessRunner()
        let shURL = URL(fileURLWithPath: "/bin/sh")

        let config = ProcessExecutionConfig(
            executableURL: shURL,
            arguments: ["-c", "echo 'something went wrong' >&2; exit 42"]
        )

        do {
            _ = try await runner.run(config: config)
            XCTFail("Expected ProcessRunnerError.executionTerminated, but succeeded")
        } catch let ProcessRunnerError.executionTerminated(exitCode, stderr) {
            XCTAssertEqual(exitCode, 42)
            XCTAssertTrue(stderr.contains("something went wrong"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
