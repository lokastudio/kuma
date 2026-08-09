---
name: kuma-testing-ci
description: Unit testing standards, Protocol Mocks, and Swift Concurrency auditing for KumaV4.
---

# Testing & Concurrency Guidelines

## 1. Protocol-Based Dependency Injection
- All Core Engine services (`ProcessRunner`, `KubeConfigParser`, `JSONImporter`) MUST be backed by protocols to enable 100% offline unit testing.

## 2. Unit Testing Execution
- Unit tests MUST run without spawning real `kubectl`/`docker` processes.
- Test closures capturing state MUST respect `@MainActor` isolation boundaries.
