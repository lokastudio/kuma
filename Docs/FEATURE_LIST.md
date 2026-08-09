# 📋 Kuma Master Feature Specification Matrix

This document defines the complete feature specifications for **Kuma (Final Edition)**, absorbing upgraded Kuma V3 features alongside new core enhancements.

---

## 🟢 1. Existing Features (Retained & Upgraded)

| Category | Feature Name | Description & Enhancements in Kuma |
|---|---|---|
| **Lifecycle** | **Splash Bootstrapper** | Window Container Splash Screen featuring fast-track onboarding detection, animated icon, & zero `Task.sleep` artificial delay. |
| **Lifecycle** | **Onboarding Wizard (4 Steps)** | Multi-step interactive onboarding: Step 1 (Welcome), Step 2 (Service Engines Check: Docker, Podman, Kubectl), Step 3 (Tunneling Tools Check: Cloudflared, Ngrok), Step 4 (Ready & Initial Workspace Setup). |
| **Lifecycle** | **Window Coordinator Engine** | Dynamic single OS Window transition (Splash -> Onboarding -> Main Workspace) without window flicker or focus loss. |
| **Workspace** | **Multi-Workspace System** | Environment service grouping with Safe Workspace Switcher (Graceful Stop All alert to prevent port conflicts). |
| **Provider** | **Kubernetes Port-Forward** | Port forwarding to K8s Pods / Deployments / Services with Process Group Isolation (`setpgid`) & auto-reconnect logic. |
| **Provider** | **Docker Compose Engine** | Up / Down service via Compose config with Process Group isolation & efficient YAML parser. |
| **Provider** | **Podman Compose Engine** | Alternative container runner via Podman CLI with orphan killer protection. |
| **Provider** | **Shell Script Execution** | Run custom scripts (`npm run dev`, `go run`) with thread-safe `$PATH` sniffer via `actor EnvironmentPathResolver`. |
| **Provider** | **SSH Tunnel Connection** | Port forwarding via Remote SSH host with Master Key AES-256 Encrypted Vault (Zero Keychain prompts). |
| **Provider** | **HTTP Health Check** | Async HTTP URL status endpoint monitoring without blocking the main UI thread. |
| **Provider** | **Public Tunneling** | Expose local ports via `cloudflared` / `ngrok` with auto-detection binary paths. |
| **Provider** | **Process Monitor** | Monitoring local OS PID active state without excessive polling loops. |
| **Services** | **Multi-Provider Switcher** | Single service multi-provider selection via Type-Safe `ProviderConfig` Enum with Auto-Context Follow UX. |
| **Services** | **Batch Operations** | One-click Start All & Stop All services with non-blocking `TaskGroup` cancellation. |
| **Services** | **Search & Filter** | Search bar service filtering & status filter with granular `@Observable` tracking (zero lag). |
| **KubeConfig**| **Multi-KubeConfig Manager** | Add/Remove/Inspect `~/.kube/config` files with `FSEvents` File System Observer. |
| **Data Sync** | **Workspace Export / Import** | Export & Import service catalog via `.json` with isolated `JSONImporter` Engine. |
| **Security**  | **Master Key Vault (AES-256-GCM)**| Safe local encryption for SSH passwords, Auth tokens, & secret configs avoiding OS Keychain popups. |
| **Audio/Alert**| **Custom Notification & Sound** | Native macOS Notification Center integration & custom sound sync (`kuma-alert.caf`). |
| **Settings**  | **Launch at Login Sync** | Automatic macOS startup integration via `ServiceManagement` (`SMAppService`). |
| **Settings**  | **Auto-Start Services** | Persisting active service states before app quit & auto-restoring upon startup. |
| **Settings**  | **Confirm Quit Safety Dialog** | Graceful confirmation dialog upon quit if active services are still running. |
| **App Safety**| **Single Instance Check** | Enforcing single app instance execution + Clean App Quit Handler (zero orphan process). |

---

## 🚀 2. New Features & Core Enhancements (Kuma Exclusive)

| Feature Name | Category | Value & Functionality |
|---|---|---|
| **Smart Sidebar Navigation** | **UX / macOS Native** | 4-Section Navigation Split View: All Active Running, Smart Filter by Active Provider, Favorites & Custom Groups, & Resource Footer. |
| **Auto-Context Follow Navigation** | **UX / Core** | Switching active provider in Inspector automatically transitions sidebar selection & main deck to new Provider View without closing Inspector. |
| **Interactive Port Conflict Resolver** | **Core / UX** | Detects PID occupying local port on start failure, providing one-click **"Kill Conflict Process"** OR **"Auto-Suggest Free Port"**. |
| **Log Coalescer & Inspector** | **Performance** | Ultra-fast log viewer (max 4-5 flushes/sec), supporting ANSI Terminal Colors, Pause Log Stream, & Clear Buffer. |
| **Native Menu Bar App (Optional Toggle)** | **macOS Native** | Status icon in macOS Menu Bar for quick Start/Stop of favorite services without opening main window. |
| **Global Keyboard Shortcuts** | **UX / Productivity** | `Cmd+R` (Restart Active Service), `Cmd+Shift+S` (Stop All), `Cmd+F` (Focus Search), `Escape` (Clear Search). |
| **Kuma FormKit & Theme System** | **Design System** | Centralized UI Tokens (`KumaTheme`), native macOS glassmorphism, zero magic numbers, & unified FormKit fields. |
