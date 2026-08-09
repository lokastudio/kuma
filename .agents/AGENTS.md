# Kuma — Golden Engineering Standards (FINAL EDITION)

> **PRIME DIRECTIVE**: Kuma is the final, production-ready architecture. All code generated MUST follow zero-compromise Swift 6 Strict Concurrency, memory safety, and thread isolation. No temporary hacks, no redundant ViewModels, no un-tracked subprocesses, no spaghetti files, no file descriptor leaks, no fat optional domain structs, no deprecated Apple APIs, no multi-dictionary state desyncs, no flat directory dumping, no coding without an approved implementation plan.

---

## 1. Fullstack Boundary & Domain Architecture
- **Layer Isolation**: `Presentation/` (@MainActor UI) ──► `Stores/` (Bridge) ──► `Core/` & `Data/` (Background Actors/Engine).
- **Universal Sub-Folder Structure**: ALL layers (`Domain/`, `Data/`, `Core/`, `Stores/`, `Presentation/`) MUST organize files into dedicated, topic-specific sub-folders (e.g. `Core/Process/`, `Domain/Models/Provider/`, `Features/Sidebar/Components/`). Dumping multiple domain files loosely inside a flat parent folder is STRICTLY FORBIDDEN.
- **ServiceAggregate Root Model**: Store state MUST encapsulate service properties inside a unified `ServiceAggregate` struct (Service, Providers, ActiveProvider, PortMappings, VaultSecrets, State). Scattered multi-dictionary state storage is STRICTLY FORBIDDEN.
- **State Machine**: Driven strictly by single `ServiceExecutionState` enum (`.stopped`, `.starting`, `.running`, `.stopping`, `.failed`). Multi-boolean flags are forbidden.
- **Type-Safe Domain Models**: Polymorphic data MUST use Swift Enums with Associated Values (Sum Types). Fat structs with 20+ optional fields are forbidden.
- **Master Key Security & Vault Secrets**: Sensitive credentials (SSH passwords, private keys, auth tokens) MUST NOT be stored in plain text inside JSON configs. All secrets MUST be encrypted via AES-256-GCM and stored inside the `vault_secrets` SQLite table.

---

## 2. Process Safety, Internal Logging & Resource Governance
- **Internal Activity Logging**: Internal app errors, DB failures, & subprocess lifecycles MUST be logged using Apple's native `os.Logger` (`OSLog`) with structured categories (`AppLifecycle`, `ProcessEngine`, `Database`). Plain `print()` statements are STRICTLY FORBIDDEN in production code.
- **Process Group Isolation**: Spawns MUST set `setpgid(0, 0)` & register in `ProcessRegistry` (Orphan Killer Protocol with `SIGINT` -> `SIGTERM` -> `SIGKILL`).
- **Cooperative Cancellation & Task Jittering**: Long-running background monitors MUST handle `Task.isCancelled` and apply initial `0-1200ms` jitter to prevent CPU/Network spikes.
- **File Descriptor Leak Prevention**: All `Pipe()` / `FileHandle` instances MUST use explicit `defer` closures to close handles.
- **FIFO RingBuffer Log Eviction**: `LogCoalescer` MUST be backed by a Circular FIFO RingBuffer (cap: 100 entries). Oldest entries MUST be evicted in `O(1)` time to guarantee zero RAM spikes.
- **Thread-Safe PATH Resolution**: PATH sniffer MUST use `actor EnvironmentPathResolver` (zero global locks).
- **Log Stream Throttling**: Logs MUST use `AsyncStream<String>` + `LogCoalescer` (max 4-5 flushes/sec, max 100 entries in RAM).

---

## 3. SwiftUI, Performance & Modern Apple SDK Rules (macOS 14+)
- **Window Coordinator & Modern Activation**: Single OS Window Scene with dynamic resizing. Single instance enforcement MUST use modern `NSRunningApplication.activate()` (Deprecated `activateIgnoringOtherApps` is forbidden).
- **Modern Launch at Login**: MUST use `SMAppService.mainApp` (`import ServiceManagement`). Legacy `SMLoginItemSetEnabled` is STRICTLY FORBIDDEN.
- **Native Glassmorphism**: Window backgrounds MUST use native `.containerBackground(.thinMaterial, for: .window)`. Legacy `NSWindow` background hacks are FORBIDDEN.
- **Security-Scoped Bookmark Persistence**: File path reads (e.g. `~/.kube/config`) MUST store persistent `bookmark_data` BLOBs in SQLite and resolve them via `URL(resolvingBookmarkData: ...)` to guarantee sandbox permissions survive app restarts.
- **Navigation & UX Standards**: Must adhere to `Docs/UX_SPECIFICATION.md`:
  - **Auto-Context Follow**: Switching active provider in Inspector MUST auto-transition Sidebar & Main Deck views to the new Provider View without closing the Inspector.
  - **Safe Workspace Switcher**: Switching workspace with active services MUST prompt the standard graceful stop confirmation dialog to prevent port conflicts (`EADDRINUSE`).
  - **Smart Sidebar & System Footer**: Sidebar navigation provides Global Views, Smart Active Provider Filters, & Custom Favorites (persisted via `is_favorite` & `service_groups`). The fixed footer strictly contains `❓ Help & Guide` and `⚙️ Settings`.
  - **Human Copywriting**: Placeholders MUST be concrete examples (`e.g. forwarder-mongo-stage`). Error messages MUST use Title + Actionable Subtext.
  - **Accessibility Compliance**: All controls MUST provide `.accessibilityLabel` and respect `@Environment(\.accessibilityReduceMotion)`.
  - **1-Click Copy Badge**: Port badges MUST be clickable to copy local URL to Clipboard with instant toast feedback.
- **Granular Observation**: Views observe Stores directly via `@Environment`. ViewModels are forbidden unless managing complex multi-step wizard state.
- **Lazy Collections**: Scrollable lists MUST use `LazyVStack` or `LazyVGrid`.
- **Max 150-Line Limit**: View files MUST be under ~150 lines. Decompose into `Views/Components/`.
- **Memory & Preview Safety**: Images MUST be downsampled via `CGImageSourceCreateThumbnailAtIndex` (ImageIO) and cached using `NSCache`. Views MUST include `#Preview` using mock data (Zero DB/Process in Previews).

---

## 4. Design System & Theme Tokens
- Mandatory `KumaTheme` tokens (spacing, radii, fonts, semantic colors). Zero magic numbers.
- All forms MUST compose `KumaFormSection` and `FormKit` components.

---

## 5. Legacy Porting Protocol & Continuous Improvement (V3 Reference Governance)
When referencing logic from Kuma V3 (`/Explore/Kuma/`):
1. **Read & Extract Only Business Logic**: Inspect the V3 implementation for core business logic, domain models, or shell scripts.
2. **Proactive Architectural Suggestions**: During porting, if the AI detects an outdated pattern, redundant data structure, or sub-optimal implementation in V3, the AI MUST explicitly suggest a modernized alternative before writing the V4 code.
3. **Strict Refactoring (Zero Copy-Paste)**: NEVER copy V3 code verbatim. All ported code MUST be refactored to comply with Swift 6 Strict Concurrency, `os.Logger`, `@Observable`, `ServiceAggregate`, and Kuma architectural rules.
4. **Purity Verification**: Ensure legacy anti-patterns (`static var shared`, un-closed `Pipe()`, `nonisolated(unsafe)`, raw `print()`, `SMLoginItemSetEnabled`, `activateIgnoringOtherApps`, multi-dictionary state) are 100% stripped.

---

## 6. Planning & Execution Workflow Protocol
- **Per-Task Implementation Plan**: Before modifying source code or writing new files for any `Docs/ROADMAP.md` task, the AI MUST generate an `implementation_plan.md` artifact detailing:
  1. Task Goal & Scope
  2. Targeted Files & Sub-Folder Paths
  3. Technical Approach & Verification Strategy
- **User Approval Required**: The AI MUST pause and wait for user approval on the plan before writing production code.
- **Pair-Programming Workflow**: Explain rationale first -> Write clean code -> Provide summary & key concepts.
- **Session Handover**: Track progress in `Docs/ROADMAP.md`. New sessions start by reading `AGENTS.md`, `Docs/UX_SPECIFICATION.md`, and `Docs/ROADMAP.md`.
- **Dynamic Adaptation**: If rules or features evolve, update `.agents/skills/*.md` or `Docs/ROADMAP.md` before coding.

---

## 7. Domain Skills Map
Refer to `.agents/skills/` for detailed implementation blueprints:
- `kuma-core-architecture`: Boundaries, Universal Sub-Folders, Window Coordinator, Docs/UX_SPECIFICATION.md Rules, Single Instance Guard, SMAppService, ServiceAggregate Root Model, Fast-Track Bootstrap, State Machine, Type-Safe Domain Models, ImageIO Downsampling, #Preview Standards
- `kuma-process-sentinel`: Subprocess Isolation, Task Jittering, Cooperative Cancellation, FIFO RingBuffer Eviction, `os.Logger` Unified Logging, AsyncStream, Pipe Deferral, EnvironmentPathResolver Actor, Orphan Killer
- `kuma-grdb-persistence`: 9-Table Schema, VaultSecrets Encryption, Security-Scoped Bookmarks Persistence (`bookmark_data`), FSEvents Disk-First Sync, Migrations, Async Repositories
- `kuma-formkit-theme`: Design Tokens, FormKit Component Specifications
- `kuma-testing-ci`: Mock Protocols & Concurrency Test Verification
