//
//  PortMapping.swift
//  Kuma
//
//  Created for Task 2.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Pure domain model representing local-to-remote port forwarding configuration for a Provider.
public struct PortMapping: Identifiable, Codable, Sendable, Equatable, Hashable {
    public let id: UUID
    public var providerId: UUID
    public var localPort: Int
    public var remotePort: Int
    public var protocolType: String
    public let createdAt: Date

    public nonisolated init(
        id: UUID = UUID(),
        providerId: UUID,
        localPort: Int,
        remotePort: Int,
        protocolType: String = "tcp",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.providerId = providerId
        self.localPort = localPort
        self.remotePort = remotePort
        self.protocolType = protocolType
        self.createdAt = createdAt
    }
}
