//
//  LogCoalescer.swift
//  Kuma
//
//  Created by Antigravity on 2026-08-09.
//

import Foundation
import os

/// A thread-safe log buffer and stream coalescer actor.
///
/// `LogCoalescer` queues incoming log lines, limits total in-memory log history
/// to a fixed capacity (FIFO eviction, default 100 lines), and coalesces rapid log emissions
/// into periodic batch flushes (default 200ms window) via `AsyncStream<[String]>`.
public actor LogCoalescer {
    private let logger = Logger(subsystem: "com.kuma.app", category: "ProcessEngine")

    public let maxCapacity: Int
    public let flushIntervalNanoseconds: UInt64

    private var buffer: [String] = []
    private var pendingBatch: [String] = []
    
    private var streamContinuation: AsyncStream<[String]>.Continuation?
    private var flushTask: Task<Void, Never>?
    private var isStopped: Bool = false

    /// Initializes a `LogCoalescer` instance.
    /// - Parameters:
    ///   - maxCapacity: Hard cap on in-memory line buffer (default: 100 lines).
    ///   - flushIntervalMilliseconds: Coalescing window in milliseconds (default: 200ms).
    public init(
        maxCapacity: Int = 100,
        flushIntervalMilliseconds: UInt64 = 200
    ) {
        self.maxCapacity = max(1, maxCapacity)
        self.flushIntervalNanoseconds = flushIntervalMilliseconds * 1_000_000
    }

    deinit {
        flushTask?.cancel()
        streamContinuation?.finish()
    }

    /// Provides an `AsyncStream` that yields batched log line updates every flush interval.
    public var stream: AsyncStream<[String]> {
        if let existingStream = currentStream {
            return existingStream
        }
        
        let (stream, continuation) = AsyncStream<[String]>.makeStream()
        self.streamContinuation = continuation
        self.currentStream = stream
        
        startFlushLoopIfNeeded()
        return stream
    }

    private var currentStream: AsyncStream<[String]>?

    // MARK: - Appending Logs

    /// Appends a single log line to the buffer and queues it for coalesced stream emission.
    /// - Parameter line: The raw log line string.
    public func append(_ line: String) {
        guard !isStopped else { return }

        // Enforce FIFO RingBuffer capacity on buffer
        buffer.append(line)
        if buffer.count > maxCapacity {
            let overflow = buffer.count - maxCapacity
            buffer.removeFirst(overflow)
        }

        // Enforce FIFO RingBuffer capacity on pendingBatch to avoid bloated UI emissions
        pendingBatch.append(line)
        if pendingBatch.count > maxCapacity {
            let overflow = pendingBatch.count - maxCapacity
            pendingBatch.removeFirst(overflow)
        }

        startFlushLoopIfNeeded()
    }

    /// Appends multiple log lines to the buffer.
    /// - Parameter lines: An array of log line strings.
    public func append(contentsOf lines: [String]) {
        guard !isStopped, !lines.isEmpty else { return }

        // Enforce FIFO RingBuffer capacity on buffer
        buffer.append(contentsOf: lines)
        if buffer.count > maxCapacity {
            let overflow = buffer.count - maxCapacity
            buffer.removeFirst(overflow)
        }

        // Enforce FIFO RingBuffer capacity on pendingBatch to avoid bloated UI emissions
        pendingBatch.append(contentsOf: lines)
        if pendingBatch.count > maxCapacity {
            let overflow = pendingBatch.count - maxCapacity
            pendingBatch.removeFirst(overflow)
        }

        startFlushLoopIfNeeded()
    }

    // MARK: - Inspection & Management

    /// Returns a snapshot of the current in-memory log buffer (up to `maxCapacity` lines).
    public func snapshot() -> [String] {
        return buffer
    }

    /// Clears all buffered log lines and pending batch emissions.
    public func clear() {
        buffer.removeAll(keepingCapacity: true)
        pendingBatch.removeAll(keepingCapacity: true)
    }

    /// Flushes any pending batch logs, cancels the periodic timer, and closes the stream continuation.
    public func stop() {
        guard !isStopped else { return }
        isStopped = true

        flushPendingBatch()

        flushTask?.cancel()
        flushTask = nil

        streamContinuation?.finish()
        streamContinuation = nil
        currentStream = nil

        logger.debug("LogCoalescer stopped successfully")
    }

    // MARK: - Private Flush Loop

    private func startFlushLoopIfNeeded() {
        guard flushTask == nil, !isStopped else { return }

        let interval = flushIntervalNanoseconds
        flushTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: interval)
                } catch {
                    break
                }

                guard let self = self else { break }
                await self.flushPendingBatch()
            }
        }
    }

    private func flushPendingBatch() {
        guard !pendingBatch.isEmpty else { return }
        let batch = pendingBatch
        pendingBatch.removeAll(keepingCapacity: true)

        streamContinuation?.yield(batch)
    }
}
