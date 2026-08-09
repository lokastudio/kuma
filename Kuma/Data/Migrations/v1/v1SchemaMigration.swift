//
//  v1SchemaMigration.swift
//  Kuma
//
//  Created for Kuma Task 3.2.
//  Governance & Concurrency: Swift 6 Strict Concurrency, GRDB DatabaseMigrator, os.Logger.
//

import Foundation
import GRDB
import os

/// Struct managing the v1 Database Schema Migration for Kuma.
public struct V1SchemaMigration: Sendable {
    
    private nonisolated static let logger = Logger(subsystem: "com.kuma.app", category: "Database")
    
    /// Registers the v1 migration on the provided GRDB `DatabaseMigrator`.
    /// - Parameter migrator: Target `DatabaseMigrator`.
    public static func register(on migrator: inout DatabaseMigrator) {
        migrator.registerMigration("v1SchemaInitialization") { db in
            logger.info("Applying v1SchemaInitialization database migration...")
            
            // 1. Table: workspaces
            try db.create(table: "workspaces") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("image_path", .text)
                t.column("sort_order", .integer).notNull().defaults(to: 0)
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
            }
            
            // 2. Table: service_groups
            try db.create(table: "service_groups") { t in
                t.column("id", .text).primaryKey()
                t.column("workspace_id", .text).notNull().references("workspaces", onDelete: .cascade)
                t.column("name", .text).notNull()
                t.column("sort_order", .integer).notNull().defaults(to: 0)
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
            }
            try db.create(index: "idx_service_groups_workspace_id", on: "service_groups", columns: ["workspace_id"])
            
            // 3. Table: services
            try db.create(table: "services") { t in
                t.column("id", .text).primaryKey()
                t.column("workspace_id", .text).notNull().references("workspaces", onDelete: .cascade)
                t.column("group_id", .text).references("service_groups", onDelete: .setNull)
                t.column("name", .text).notNull()
                t.column("description", .text)
                t.column("is_disabled", .boolean).notNull().defaults(to: false)
                t.column("is_favorite", .boolean).notNull().defaults(to: false)
                t.column("active_provider_id", .text) // Note: Application-level relation, zero DDL FK to avoid circular locks
                t.column("last_status", .text).notNull().defaults(to: "stopped")
                t.column("last_active_port", .integer)
                t.column("sort_order", .integer).notNull().defaults(to: 0)
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
            }
            try db.create(index: "idx_services_workspace_id", on: "services", columns: ["workspace_id"])
            try db.create(index: "idx_services_group_id", on: "services", columns: ["group_id"])
            
            // 4. Table: kubeconfigs
            try db.create(table: "kubeconfigs") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("path", .text).notNull()
                t.column("bookmark_data", .blob)
                t.column("config_content_encrypted", .blob)
                t.column("is_default", .boolean).notNull().defaults(to: false)
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
            }
            
            // 5. Table: providers
            try db.create(table: "providers") { t in
                t.column("id", .text).primaryKey()
                t.column("service_id", .text).notNull().references("services", onDelete: .cascade)
                t.column("label", .text)
                t.column("provider_type", .text).notNull()
                t.column("config_json", .text).notNull()
                t.column("kube_config_id", .text).references("kubeconfigs", onDelete: .setNull)
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
            }
            try db.create(index: "idx_providers_service_id", on: "providers", columns: ["service_id"])
            try db.create(index: "idx_providers_kube_config_id", on: "providers", columns: ["kube_config_id"])
            
            // 6. Table: port_mappings
            try db.create(table: "port_mappings") { t in
                t.column("id", .text).primaryKey()
                t.column("provider_id", .text).notNull().references("providers", onDelete: .cascade)
                t.column("local_port", .integer).notNull()
                t.column("remote_port", .integer).notNull()
                t.column("protocol", .text).notNull().defaults(to: "TCP")
                t.column("created_at", .datetime).notNull()
            }
            try db.create(index: "idx_port_mappings_provider_id", on: "port_mappings", columns: ["provider_id"])
            
            // 7. Table: vault_secrets
            try db.create(table: "vault_secrets") { t in
                t.column("id", .text).primaryKey()
                t.column("provider_id", .text).notNull().references("providers", onDelete: .cascade)
                t.column("secret_type", .text).notNull()
                t.column("ciphertext_base64", .text).notNull()
                t.column("nonce_base64", .text).notNull()
                t.column("updated_at", .datetime).notNull()
            }
            try db.create(index: "idx_vault_secrets_provider_id", on: "vault_secrets", columns: ["provider_id"])
            
            // 8. Table: master_key_vault
            try db.create(table: "master_key_vault") { t in
                t.column("id", .text).primaryKey()
                t.column("salt_base64", .text).notNull()
                t.column("key_check_hash", .text).notNull()
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
            }
            
            // 9. Table: settings
            try db.create(table: "settings") { t in
                t.column("key", .text).primaryKey()
                t.column("value", .text).notNull()
                t.column("updated_at", .datetime).notNull()
            }
            
            logger.info("Completed v1SchemaInitialization database migration successfully.")
        }
    }
}
