import XCTest
@testable import Kuma

final class CircularLogBufferTests: XCTestCase {
    
    func testBufferInitializationAndCapacity() {
        let buffer = CircularLogBuffer(capacity: 10)
        XCTAssertEqual(buffer.capacity, 10)
        XCTAssertTrue(buffer.snapshot().isEmpty)
    }
    
    func testAppendAndSnapshotOrdering() {
        let buffer = CircularLogBuffer(capacity: 5)
        buffer.append("Line 1")
        buffer.append("Line 2")
        buffer.append("Line 3")
        
        let snap = buffer.snapshot()
        XCTAssertEqual(snap.count, 3)
        XCTAssertEqual(snap[0].message, "Line 1")
        XCTAssertEqual(snap[1].message, "Line 2")
        XCTAssertEqual(snap[2].message, "Line 3")
    }
    
    func testFifoEvictionWhenExceedingCapacity() {
        let buffer = CircularLogBuffer(capacity: 3)
        buffer.append("Log A")
        buffer.append("Log B")
        buffer.append("Log C")
        buffer.append("Log D") // Evicts Log A
        buffer.append("Log E") // Evicts Log B
        
        let snap = buffer.snapshot()
        XCTAssertEqual(snap.count, 3)
        XCTAssertEqual(snap[0].message, "Log C")
        XCTAssertEqual(snap[1].message, "Log D")
        XCTAssertEqual(snap[2].message, "Log E")
    }
    
    func testClearBuffer() {
        let buffer = CircularLogBuffer(capacity: 5)
        buffer.append("Line 1")
        buffer.append("Line 2")
        
        buffer.clear()
        XCTAssertTrue(buffer.snapshot().isEmpty)
    }
    
    func testMultiThreadedConcurrentAppends() {
        let buffer = CircularLogBuffer(capacity: 50)
        let expectation = expectation(description: "Concurrent appends")
        expectation.expectedFulfillmentCount = 100
        
        DispatchQueue.concurrentPerform(iterations: 100) { i in
            buffer.append("Message \(i)")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
        
        let snap = buffer.snapshot()
        XCTAssertEqual(snap.count, 50, "Buffer count should be capped at capacity (50)")
    }
}
