//
//  ProviderRecord.swift
//  Kuma
//
//  Created for Task 3.5 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB

/// GRDB Record mapping `providers` SQLite table to `Provider` domain model.
public struct ProviderRecord: Codable, FetchableRecord, PersistableRecord, TableRecord, Sendable {
    public static let databaseTableName = "providers"

    public var id: UUID
    public var serviceId: UUID
    public var label: String?
    public var providerType: String
    public var configJson: String
    public var kubeConfigId: UUID?
    public var createdAt: Date
    public var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case serviceId = "service_id"
        case label
        case providerType = "provider_type"
        case configJson = "config_json"
        case kubeConfigId = "kube_config_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public init(
        id: UUID,
        serviceId: UUID,
        label: String? = nil,
        providerType: String,
        configJson: String,
        kubeConfigId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.serviceId = serviceId
        self.label = label
        self.providerType = providerType
        self.configJson = configJson
        self.kubeConfigId = kubeConfigId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Convert from domain model
    public init(from domain: Provider) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(domain.config)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(
                domain.config,
                EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Failed to encode ProviderConfig to UTF-8 String"
                )
            )
        }

        self.id = domain.id
        self.serviceId = domain.serviceId
        self.label = domain.label
        self.providerType = domain.providerType.rawValue
        self.configJson = jsonString
        self.kubeConfigId = domain.kubeConfigId
        self.createdAt = domain.createdAt
        self.updatedAt = domain.updatedAt
    }

    /// Convert to domain model
    public nonisolated func toDomain() throws -> Provider {
        guard let data = configJson.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Invalid UTF-8 JSON string in ProviderRecord configJson"
                )
            )
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let config = try decoder.decode(ProviderConfig.self, from: data)

        return Provider(
            id: id,
            serviceId: serviceId,
            label: label,
            config: config,
            kubeConfigId: kubeConfigId,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
