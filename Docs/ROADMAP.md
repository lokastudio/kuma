# 🗺️ Kuma Master Development Roadmap

> **Status Tracking**: All tasks are strictly sequential. Check off items upon completion & verification.

---

## 🏗️ Phase 1: Governance & Specification Lockdown
- [x] **1.1** Establish `.agents/` Top-Tier Governance Rules & Skills Map (Swift 6 & `os.Logger` Integrated)
- [x] **1.2** Establish `FEATURE_LIST.md` Master Specification (Including 4-Step Onboarding, Menu Bar App, & Master Key Vault)
- [x] **1.3** Establish `UX_SPECIFICATION.md` Master Navigation Specs (Smart Sidebar, Auto-Context Follow, & Accessibility)
- [x] **1.4** Establish `ERD.md` Master Database Schema (9 Tables Normalized with `vault_secrets` & `service_groups`)
- [x] **1.5** Establish `PROMPT_TEMPLATES.md` High-Precision AI Session Handover Templates
- [x] **1.6** Setup `ROADMAP.md` Session Handover & Adaptation Protocol System
- [x] **1.7** Xcode Project Initial Setup (`Kuma.xcodeproj` with Swift 6 Strict Concurrency) & Shared Utilities Directory (`Lib/`)

---

## 💎 Phase 2: Domain Layer & Type-Safe Models (Zero Dependency)
- [x] **2.1** `ServiceExecutionState` Enum (State Machine: `.stopped`, `.starting`, `.running`, `.stopping`, `.failed`)
- [x] **2.2** `ProviderConfig` Associated Value Enum (Kube, Docker, Podman, Shell, SSH, HTTPCheck, Tunnel, ProcessMonitor)
- [x] **2.3** `Service`, `Provider`, `Workspace`, `ServiceGroup`, `VaultSecret`, `KubeConfig`, `PortMapping` Domain Structs
- [x] **2.4** `SystemDependency` Enum & Requirement Types

---

## 💾 Phase 3: Data Layer & Persistence (GRDB SQLite Engine)
- [x] **3.1** `DatabaseManager` Setup with Thread-Safe `dbQueue`
- [x] **3.2** Database Migrations (v1 Schema Initialization: `workspaces`, `service_groups`, `services`, `providers`, `port_mappings`, `vault_secrets`, `kubeconfigs`, `master_key_vault`, `settings`)
- [x] **3.3** `WorkspaceRepository` & `ServiceGroupRepository` (Async CRUD & Batch Fetching)
- [x] **3.4** `ServiceRepository` (Async JOIN Queries, `last_status` restoration & Bulk Operations)
- [x] **3.5** `KubeConfigRepository` & `ProviderRepository` (Disk-First FSEvents Sync)
- [x] **3.6** `MasterKeyVault` & `VaultSecretRepository` Engine (AES-256-GCM Local Secret Encryption)

---

## ⚙️ Phase 4: Core Process Engine (Backend Layer)
- [x] **4.1** `actor EnvironmentPathResolver` (Thread-Safe Shell PATH Sniffer)
- [x] **4.2** `ProcessRegistry` (Thread-Safe PID Tracker & Graceful `SIGINT->SIGTERM->SIGKILL` Orphan Killer)
- [x] **4.3** `ProcessRunner` (Spawn Subprocess with `setpgid` & Explicit Pipe Deferral)
- [x] **4.4** `LogCoalescer` (Buffered `AsyncStream<String>` with 200ms Throttling)
- [x] **4.5** `ServiceExecutionEngine` (Orchestrates Execution via `ServiceExecutionState`)
- [x] **4.6** `JSONImporter` & `MigrationEngine` (Safe Team Workspace Sync)
- [x] **4.7** `PortConflictResolver` (PID Detection & Auto-Free Port Suggestion)
- [x] **4.8** `KumaSoundManager` (Custom Sound Effects & `~/Library/Sounds/` Notification Sync)

---

## 🎨 Phase 5: Design System & Kuma FormKit (UI Tokens)
- [x] **5.1** `KumaTheme` Tokens (Fonts, Spacing, Radii, Semantic Colors)
- [x] **5.2** `KumaFormSection` & Layout Containers
- [x] **5.3** `KumaTextField`, `KumaPickerField`, `KumaToggleField`, `KumaSecureField` (Contextual Placeholders & Focus Rings)
- [x] **5.4** `KumaPortMappingEditor`, `KumaKeyValueEditor`, `KumaListManager`

---

## 🌉 Phase 6: Stores Layer (State Observation & Bridge)
- [x] **6.1** `AppStore` (@Observable Root Container & AppPhase State Machine)
- [x] **6.2** `WorkspaceStore` (@Observable Workspace State & `NSCache` Avatars)
- [ ] **6.3** `ServiceStore` (@Observable Service Management & Auto-Start Restoration Logic via `ServiceAggregate`)
- [ ] **6.4** `KubeConfigStore` (@Observable KubeContext Sync & FSEvents Observer)

---

## 🖥️ Phase 7: Presentation Layer & Views (Frontend UI)
- [ ] **7.1** `WindowCoordinator` & Single OS Window Container
- [ ] **7.2** `SplashView` (Animated App Icon, Zero Heavy Allocation, Fast-Track Detection, `#Preview`)
- [ ] **7.3** `OnboardingView` (4-Step Wizard: Welcome -> Engines -> Tunneling -> Ready)
- [ ] **7.4** `SidebarView` (Smart 4-Section Split Navigation with Custom UI support)
- [ ] **7.5** `ServicesDeckView` (`LazyVStack` Grid, Search Filter, Auto-Context Follow, Quick Actions)
- [ ] **7.6** `ServiceCardView` (Status Pills, Provider Badges, Accessibility Labels, Hover Effects)
- [ ] **7.7** `ServiceInspectorView` (Logs Stream Viewer with Coalescing, Port Resolver UI, Human Copywriting)
- [ ] **7.8** `SettingsView` (General, Launch at Login, Auto-Start, Confirm Quit Safety)
- [ ] **7.9** `MenuBarApp` (Native Status Item Controller & Quick Toggle Menu)

---

## 🧪 Phase 8: Verification & Production Release
- [ ] **8.1** Memory Leak & File Descriptor Audit (`lsof` & Xcode Leaks Instrument)
- [ ] **8.2** Process Termination Test (Force Quit -> Zero Orphan Process Check)
- [ ] **8.3** Unit Tests Execution (Offline Protocol Mocks)
- [ ] **8.4** Final Build & Entitlements Release
