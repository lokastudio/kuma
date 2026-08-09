//
//  WorkspaceExportPayload.swift
//  Kuma
//
//  Created for Task 4.6 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Payload versioning for JSON export/import compatibility.
public enum ExportPayloadVersion: String, Codable, Sendable {
    case v1 = "1.0.0"
}

/// Codable payload representing a complete workspace snapshot for team sharing & migration.
public struct WorkspaceExportPayload: Codable, Sendable, Equatable {
    public let version: ExportPayloadVersion
    public let exportedAt: Date
    public let workspace: Workspace
    public let groups: [ServiceGroup]
    public let services: [Service]
    public let providers: [Provider]
    public let portMappings: [PortMapping]

    public init(
        version: ExportPayloadVersion = .v1,
        exportedAt: Date = Date(),
        workspace: Workspace,
        groups: [ServiceGroup],
        services: [Service],
        providers: [Provider],
        portMappings: [PortMapping]
    ) {
        self.version = version
        self.exportedAt = exportedAt
        self.workspace = workspace
        self.groups = groups
        self.services = services
        self.providers = providers
        self.portMappings = portMappings
    }
}
