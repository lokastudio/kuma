# 🎨 Kuma Master UX & Navigation Specification

This document defines the UX navigation standards, Sidebar behavior, Auto-Context Follow rules, Safe Workspace Switcher, Accessibility, and Human Copywriting guidelines for **Kuma**.

---

## 🏛️ 1. Smart Sidebar Architecture & Hierarchy

Kuma Sidebar utilizes native macOS `NavigationSplitView` / `SidebarListStyle()` (with custom visual design by User). Navigation content is structured into distinct sections:

```
┌───────────────────────────────────────────────┐
│  🟢 🟡 🔴  KUMA SIDEBAR                       │
├───────────────────────────────────────────────┤
│  SECTION 1: GLOBAL MASTER VIEWS               │
│  ├── 🟢 All Active Running                    │
│  └── 📁 All Services Deck                     │
├───────────────────────────────────────────────┤
│  SECTION 2: BY ACTIVE PROVIDER (Smart Filter) │
│  ├── ☸️ Kubernetes (Port-Forward)    [ 4 ]     │
│  ├── 🐳 Docker Compose               [ 2 ]     │
│  ├── 🐚 Shell Scripts                [ 3 ]     │
│  └── 🔒 SSH Tunnels                  [ 1 ]     │
├───────────────────────────────────────────────┤
│  SECTION 3: FAVORITES & CUSTOM GROUPS         │
│  ├── 📌 Daily Backend Stack                   │
│  │   ├── 🟢 Mongo (K8s)                       │
│  │   └── 🟢 Postgres (Docker)                 │
│  └── 📌 Payment Gateway Debugging             │
│      └── ⚪️ Midtrans Mock (Shell)             │
├───────────────────────────────────────────────┤
│  SECTION 4: SYSTEM FOOTER (Fixed Bottom Bar)  │
│  ├── ❓ Help & Guide                          │
│  └── ⚙️ Settings                              │
└───────────────────────────────────────────────┘
```

### Critical UI/UX Notes:
1. **Navigation Footer**: The bottom fixed footer strictly contains **`❓ Help & Guide`** and **`⚙️ Settings`** (aligning with existing Kuma standards). KubeConfig Manager is unified within Settings/Wizard.
2. **UI Customization**: Visual layout/styling of the Sidebar is custom-crafted by User, while filter logic & state structure strictly obey the section schema above.

---

## ⚡ 2. Auto-Context Follow Rule (Switch Provider in Inspector)

When a user modifies a service's active provider in the Right Inspector Panel while viewing a provider-filtered page:

### Behavioral Flow:
1. **State Trigger**: User changes active provider (e.g. from **Kubernetes -> Docker Compose**) in Inspector.
2. **Auto-Navigation Shift**: 
   - Sidebar highlight automatically transitions from `☸️ Kubernetes` to load the Docker Compose View.
3. **Inspector Continuity**: Right Inspector Panel **REMAINS OPEN & ACTIVE** targeting the service without reset/close.
4. **Badge Auto-Update**: Count badges in Kubernetes decrement and Docker increment in real-time.

---

## 🛡️ 3. Safe Workspace Switcher (Zero Port Conflict Rule)

To prevent local port conflicts (`EADDRINUSE`) across workspaces:

### Behavioral Flow:
1. **Active Check**: Triggered when a user clicks Workspace B in sidebar while active services are running in Workspace A.
2. **Alert Reuse Pattern**: Prompts native macOS confirmation alert mirroring the Graceful Shutdown pattern (`applicationShouldTerminate`):
   - **Title**: *"Switch Workspace?"*
   - **Text**: *"Active services are still running in 'Workspace A'. Would you like to stop all running services in this workspace and switch, or cancel?"*
   - **Buttons**: `[ Stop Services & Switch ]` (Primary Accent) | `[ Cancel ]` (Secondary).
3. **Execution**: Upon approval, Kuma executes `stopAll()` on Workspace A gracefully before transitioning the viewport to Workspace B.

---

## 🖥️ 4. 3-Pane Split Layout Specification

```
┌───────────────┬───────────────────────────────┬───────────────────────────────┐
│  1. SIDEBAR   │   2. MAIN SERVICES DECK       │   3. INSPECTOR DRAWER PANEL   │
│               │                               │                               │
│  (Navigation  │  (List Card Services based    │  (Opens on right when service │
│   & Smart     │   on active sidebar selection)│   card is selected/clicked)   │
│   Provider    │                               │                               │
│   Group)      │                               │  - Log Stream Output          │
│               │  [ 🟢 Postgres (K8s) ]        │  - Switch Provider Toggle     │
│               │  [ 🟢 Redis (Docker) ]        │  - Port Mappings Editor       │
│               │  [ ⚪️ Mongo (Shell)  ]        │  - Interactive Port Resolver  │
└───────────────┴───────────────────────────────┴───────────────────────────────┘
```

---

## 💬 5. Voice, Tone, Placeholders & Human Copywriting

All text, placeholders, and error messages in Kuma MUST adhere to **Human-Centered Copywriting**:

1. **Contextual Placeholders**:
   - Generic placeholders like *"Enter text here..."* are STRICTLY FORBIDDEN.
   - MUST provide concrete, relevant examples:
     - Target Name: *"e.g. forwarder-mongo-stage or pod/mongo-0"*
     - Run Command: *"e.g. npm run dev or go run main.go"*
     - Host Path: *"e.g. ~/.kube/config or /etc/hosts"*
2. **Human-Readable Error Messages**:
   - Format: **Short Title + Actionable Solution Subtext**:
     - `EADDRINUSE` ──► **UI Title**: *"Port 5432 is Already in Use"* | **Sub-Text**: *"Occupied by PID 1234. Click to auto-free or resolve."*
     - `kubectl not found` ──► **UI Title**: *"Kubectl CLI Not Found"* | **Sub-Text**: *"Please install kubectl via Homebrew or specify path in Settings."*
3. **Action-Oriented Empty States**:
   - Empty states must provide actionable guidance: *"No Services in this Workspace"* | Sub-Text: *"Click '+ Add Service' to configure your first K8s, Docker, or Shell service."*

---

## ♿️ 6. macOS Accessibility & Keyboard Shortcuts

1. **Accessibility Labels**: All icon-only buttons (`▶`, `⏹`, `⚙️`, `+`) MUST provide explicit `accessibilityLabel` for VoiceOver users.
2. **Reduce Motion Compliance**: Floating animations and spring transitions MUST degrade gracefully to instant/fade if `accessibilityReduceMotion` is active.
3. **Keyboard Shortcuts**:
   - `Escape` Key: Instant clear search query & reset main deck view.
   - `Cmd + R`: Restart selected active service.
   - `Cmd + Shift + S`: Stop all running services.

---

## ⚡️ 7. Real Productivity Micro-Interactions

1. **1-Click Copy Port Badge**:
   - Clicking Port Badge (e.g. `5432` / `localhost:8080`) on Service Card or Inspector directly copies local URL to Clipboard with instant toast feedback (*Copied to Clipboard!*).
