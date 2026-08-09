---
name: kuma-core-architecture
description: Single Window Coordinator, ServiceAggregate Root Model, Enum State Machine, Type-Safe Associated Enums, LazyVStack Layouts, SMAppService Launch at Login, 150-line file limit, Single Instance Activation, Hardware Image Downsampling, and SwiftUI #Preview Standards for KumaV4.
---

# SwiftUI Architecture & Domain Guidelines

## 1. Single Window / Window Coordinator & Single Instance Guard
- Orchestrate OS Window state via `AppStore.appPhase` or `WindowCoordinator`.
- NEVER call `openWindow`/`dismissWindow` inside SwiftUI View `.onChange` closures directly.
- Single instance enforcement MUST use `NSRunningApplication.runningApplications(withBundleIdentifier:)` with macOS 14+ `activate()` API (Deprecated `activateIgnoringOtherApps` is STRICTLY FORBIDDEN).

## 2. ServiceAggregate Root Model (Zero Multi-Dictionary Desync)
- Stores MUST NOT maintain separate dictionaries for service metadata (e.g. `serviceStates`, `activeProviders`, `portMappings`).
- Data MUST be encapsulated inside a single `ServiceAggregate` struct:
  ```swift
  struct ServiceAggregate: Identifiable, Equatable, Sendable {
      var service: Service
      var providers: [Provider]
      var activeProvider: Provider?
      var portMappings: [PortMapping]
      var state: ServiceExecutionState
  }
  ```

## 3. Enum State Machine & Type-Safe Domain Models
- Service execution MUST use `ServiceExecutionState`:
  ```swift
  enum ServiceExecutionState: Equatable {
      case stopped
      case starting(progress: String)
      case running(pid: Int32, activePort: Int)
      case stopping
      case failed(error: String)
  }
  ```
- Domain models MUST use **Enum with Associated Values** (Sum Types) for variant data (e.g. `ProviderConfig` enum instead of a single fat struct with 20+ optional fields). Zero optional field leaking across provider types.

## 4. Modern Launch at Login & Native Glassmorphism
- Launch at Login MUST use Apple's modern `SMAppService.mainApp` API (`import ServiceManagement`). Legacy `SMLoginItemSetEnabled` is STRICTLY FORBIDDEN.
- Window backgrounds MUST use native SwiftUI `.containerBackground(.thinMaterial, for: .window)` and `.toolbarBackgroundVisibility(.hidden, for: .windowToolbar)`.

## 5. Anti-Spaghetti & Performance Rules
- **Lazy Collections**: Scrollable lists MUST use `LazyVStack` or `LazyVGrid`. Never use plain `VStack` inside `ScrollView` for dynamic items.
- **150-Line Limit**: View files MUST be under ~150 lines. Decompose into `Views/Components/[Name]View.swift`.
- **NSCache & Hardware Image Downsampling**: Workspace avatar images MUST be downsampled using `CGImageSourceCreateThumbnailAtIndex` (max 256px) via `ImageIO` before loading into RAM to prevent memory spikes. Plain Dictionaries for image caches are FORBIDDEN.

## 6. Mandatory `#Preview` Mocking Rule
- Every View file MUST include Swift 5.9+ `#Preview` macro block (except App entry points).
- Previews MUST use `AppStore.mock` or static sample domain models.
- NEVER initialize `DatabaseManager.shared` or spawn `ProcessRunner` inside a `#Preview`.
