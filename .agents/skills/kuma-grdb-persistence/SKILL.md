---
name: kuma-grdb-persistence
description: SQLite GRDB 9-table database operations, Security-Scoped Bookmark BLOB persistence, VaultSecrets AES-256 encryption, ServiceAggregate integrity, KubeConfig dual-mode sync, and zero N+1 queries for Kuma.
---

# GRDB Persistence & File I/O Guidelines

## 1. Non-Blocking Async Database Access
- All repository methods MUST be `async throws`. Never perform synchronous DB access on `@MainActor` or the main thread.
- Use `dbQueue.read` and `dbQueue.write` transactions explicitly.

## 2. Security-Scoped Bookmark Persistence (macOS App Sandbox)
- Disk file paths selected via `NSOpenPanel` (e.g. `~/.kube/config`) MUST generate Security-Scoped Bookmark byte data (`URL.bookmarkData(options: .withSecurityScope, ...)`).
- Bookmark BLOB byte data MUST be persisted in `kubeconfigs.bookmark_data` column in SQLite.
- Upon app startup / restart, `KubeConfigRepository` MUST resolve the bookmark data (`URL(resolvingBookmarkData: ...)`) to maintain file read permissions permanently across restarts.

## 3. Relational Query Sources of Truth & Vault Secrets
- `providers.kube_config_id` relational FK is the **Primary Source of Truth for SQL JOIN queries** between providers and KubeConfigs.
- Encrypted secrets (SSH passwords, SSH private keys, Auth tokens) MUST NOT be stored in plain text inside `providers.config_json`. All secrets MUST be encrypted via Master Key Vault (AES-256-GCM) and persisted inside the dedicated `vault_secrets` table.

## 4. Circular Foreign Key Avoidance & Favorites Management
- Do NOT define DDL Foreign Key constraints on `services.active_provider_id` -> `providers.id` to prevent SQLite circular FK locks with `providers.service_id`.
- Referential integrity of `active_provider_id` MUST be validated application-side inside `ServiceAggregate` during repository batch fetches.
- Sidebar Favorites & Custom Groups MUST be persisted via `services.is_favorite` and `service_groups` table references.
- Column `services.last_status` MUST only persist STABLE states (`stopped`, `running`, `failed`). Transient states (`starting`/`stopping`) automatically fallback to `stopped` on app startup restoration.

## 5. Batch Operations & Query Efficiency
- Zero N+1 queries. Use batch fetches or SQL JOINs when loading Services with Providers, Port Mappings, & Vault Secrets.
- All bulk writes (> 10 rows) MUST be executed within a single transaction.
