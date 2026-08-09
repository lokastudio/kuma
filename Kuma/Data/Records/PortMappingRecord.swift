//
//  PortMappingRecord.swift
//  Kuma
//
//  Created for Task 3.5 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB

/// GRDB Record mapping `port_mappings` SQLite table to `PortMapping` domain model.
public struct PortMappingRecord: Codable, FetchableRecord, PersistableRecord, TableRecord, Sendable {
    public static let databaseTableName = "port_mappings"

    public var id: UUID
    public var providerId: UUID
    public var localPort: Int
    public var remotePort: Int
    public var protocolType: String
    public var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case providerId = "provider_id"
        case localPort = "local_port"
        case remotePort = "remote_port"
        case protocolType = "protocol"
        case createdAt = "created_at"
    }

    public init(
        id: UUID,
        providerId: UUID,
        localPort: Int,
        remotePort: Int,
        protocolType: String = "TCP",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.providerId = providerId
        self.localPort = localPort
        self.remotePort = remotePort
        self.protocolType = protocolType
        self.createdAt = createdAt
    }

    /// Convert from domain model
    public init(from domain: PortMapping) {
        self.id = domain.id
        self.providerId = domain.providerId
        self.localPort = domain.localPort
        self.remotePort = domain.remotePort
        self.protocolType = domain.protocolType
        self.createdAt = domain.createdAt
    }

    /// Convert to domain model
    public nonisolated var toDomain: PortMapping {
        PortMapping(
            id: id,
            providerId: providerId,
            localPort: localPort,
            remotePort: remotePort,
            protocolType: protocolType,
            createdAt: createdAt
        )
    }
}
