//
//  Provider.swift
//  Kuma
//
//  Created for Task 2.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Pure domain model representing an execution Provider configuration attached to a Service.
public struct Provider: Identifiable, Codable, Sendable, Equatable, Hashable {
    public let id: UUID
    public var serviceId: UUID
    public var label: String?
    public var config: ProviderConfig
    public var kubeConfigId: UUID?
    public let createdAt: Date
    public var updatedAt: Date

    /// Computed property derived directly from `config.providerType` to eliminate state desync bugs.
    public nonisolated var providerType: ProviderType {
        config.providerType
    }

    public nonisolated init(
        id: UUID = UUID(),
        serviceId: UUID,
        label: String? = nil,
        config: ProviderConfig,
        kubeConfigId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.serviceId = serviceId
        self.label = label
        self.config = config
        self.kubeConfigId = kubeConfigId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
