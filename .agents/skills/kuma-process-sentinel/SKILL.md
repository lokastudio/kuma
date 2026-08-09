---
name: kuma-process-sentinel
description: Subprocess Group isolation (setpgid), FIFO RingBuffer Log Eviction, Task Jittering, Cooperative Cancellation, AsyncStream logging, FileHandle close deferral, EnvironmentPathResolver actor, and SIGINT->SIGTERM->SIGKILL Orphan Killer for Kuma.
---

# Process Engine & Subprocess Guidelines

## 1. Process Group Isolation (`setpgid`)
- All spawned processes (`kubectl`, `docker`, `podman`, `shell`) MUST use `setpgid(0, 0)` to create an isolated Process Group.
- Process handles MUST be registered with `ProcessRegistry.shared` immediately upon launch.

## 2. FIFO RingBuffer Log Eviction & Stream Throttling
- Log outputs from `AsyncStream<String>` MUST pass through `LogCoalescer` (flushing window: 200–250ms).
- `LogCoalescer` MUST be backed by a **Circular FIFO RingBuffer** with a strict capacity ceiling of **100 log lines**.
- When log line count exceeds 100 entries, oldest entries MUST be evicted immediately in `O(1)` time (`removeFirst()`). Memory allocation for active log buffers MUST remain constant regardless of log volume.

## 3. Cooperative Task Cancellation & Initial Jittering
- All async process execution and background monitoring tasks MUST check `Task.isCancelled` before and after async I/O:
  ```swift
  if Task.isCancelled {
      throw CancellationError()
  }
  ```
- Background periodic monitors (HealthCheck / ProcessMonitor) MUST apply an initial random jitter (`0...1200ms`) to prevent concurrent CPU/Network spikes across multiple services.

## 4. File Descriptor Leak Prevention (Mandatory `defer`)
- Every `Pipe()` or `FileHandle` created for subprocess I/O MUST be explicitly closed using a `defer` block:
  ```swift
  defer {
      try? pipe.fileHandleForReading.closeFile()
      try? pipe.fileHandleForWriting.closeFile()
  }
  ```
- Un-closed file handles are STRICTLY FORBIDDEN to prevent `Too many open files (errno 24)` crashes.

## 5. Thread-Safe Path Resolution (`actor EnvironmentPathResolver`)
- PATH resolution MUST be managed by a thread-safe `actor EnvironmentPathResolver`.
- Using `nonisolated(unsafe)` static variables or manual `NSLock` for PATH resolution is STRICTLY FORBIDDEN.
- User shell detection MUST read `ProcessInfo.processInfo.environment["SHELL"]` dynamically (zsh/fish/bash support).

## 6. Graceful Orphan Killer Protocol (SIGINT -> SIGTERM -> SIGKILL)
- Upon application termination (`applicationWillTerminate`) or service cancellation:
  1. Issue `SIGINT` (Interrupt / Ctrl+C) to give container runners (e.g. Docker / Node.js) 300ms to clean lockfiles.
  2. Issue `SIGTERM` (Terminate) to the Process Group with a 500ms timeout.
  3. Issue `SIGKILL` (Force Kill) as a final safety net for any stubborn child PIDs.
