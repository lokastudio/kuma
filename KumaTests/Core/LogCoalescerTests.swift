//
//  LogCoalescerTests.swift
//  KumaTests
//
//  Created by Antigravity on 2026-08-09.
//

import XCTest
@testable import Kuma

final class LogCoalescerTests: XCTestCase {

    func testFifoEvictionAtMaxCapacity() async {
        let coalescer = LogCoalescer(maxCapacity: 100, flushIntervalMilliseconds: 50)

        // Append 150 lines
        for i in 1...150 {
            await coalescer.append("Line \(i)")
        }

        let snapshot = await coalescer.snapshot()
        XCTAssertEqual(snapshot.count, 100)
        XCTAssertEqual(snapshot.first, "Line 51")
        XCTAssertEqual(snapshot.last, "Line 150")
    }

    func testBatchStreamEmission() async throws {
        let coalescer = LogCoalescer(maxCapacity: 100, flushIntervalMilliseconds: 50)
        let stream = await coalescer.stream

        Task {
            await coalescer.append("Line 1")
            await coalescer.append("Line 2")
            await coalescer.append("Line 3")
        }

        var receivedBatches: [[String]] = []
        for await batch in stream {
            receivedBatches.append(batch)
            if receivedBatches.flatMap({ $0 }).count >= 3 {
                await coalescer.stop()
                break
            }
        }

        let totalLines = receivedBatches.flatMap { $0 }
        XCTAssertEqual(totalLines, ["Line 1", "Line 2", "Line 3"])
    }

    func testClearAndStop() async {
        let coalescer = LogCoalescer(maxCapacity: 100, flushIntervalMilliseconds: 50)
        await coalescer.append("Log before clear")

        await coalescer.clear()
        let snapshotAfterClear = await coalescer.snapshot()
        XCTAssertTrue(snapshotAfterClear.isEmpty)

        await coalescer.append("Log before stop")
        await coalescer.stop()

        await coalescer.append("Log after stop")
        let snapshotAfterStop = await coalescer.snapshot()
        XCTAssertEqual(snapshotAfterStop, ["Log before stop"])
    }
}
