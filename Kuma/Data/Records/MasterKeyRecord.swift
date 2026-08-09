//
//  MasterKeyRecord.swift
//  Kuma
//
//  Created for Task 3.6 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB

/// GRDB Record representation of the `master_key_vault` database table.
public struct MasterKeyRecord: Codable, FetchableRecord, PersistableRecord, Sendable, Equatable {
    public static let databaseTableName = "master_key_vault"

    public var id: String
    public var salt_base64: String
    public var key_check_hash: String
    public var created_at: Date
    public var updated_at: Date

    public init(
        id: String = "master_key",
        salt_base64: String,
        key_check_hash: String,
        created_at: Date = Date(),
        updated_at: Date = Date()
    ) {
        self.id = id
        self.salt_base64 = salt_base64
        self.key_check_hash = key_check_hash
        self.created_at = created_at
        self.updated_at = updated_at
    }
}
