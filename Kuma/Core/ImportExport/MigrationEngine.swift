//
//  MigrationEngine.swift
//  Kuma
//
//  Created for Task 4.6 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import GRDB
import os

/// Strategy for resolving conflicts during workspace JSON import.
public enum ImportConflictStrategy: Sendable {
    case replace
    case duplicateAsNew
}

/// Transactional engine orchestrating safe, atomic workspace imports into the SQLite GRDB database.
public final class MigrationEngine: Sendable {

    private let dbWriter: any DatabaseWriter
    private let logger = Logger(subsystem: "com.kuma.app", category: "Database")

    public init(dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
    }

    /// Import a workspace payload atomically inside a single GRDB write transaction.
    @discardableResult
    public func importWorkspace(
        _ payload: WorkspaceExportPayload,
        strategy: ImportConflictStrategy
    ) async throws -> Workspace {
        let now = Date()

        let importedWorkspace: Workspace = try await dbWriter.write { db in
            var createdWs: Workspace?
            try db.inTransaction {
                let ws: Workspace

                switch strategy {
                case .replace:
                    ws = payload.workspace
                    var wsRecord = WorkspaceRecord(from: ws)
                    wsRecord.updatedAt = now
                    try wsRecord.save(db)

                    for group in payload.groups {
                        var rec = ServiceGroupRecord(from: group)
                        rec.updatedAt = now
                        try rec.save(db)
                    }

                    for service in payload.services {
                        var rec = ServiceRecord(from: service)
                        rec.updatedAt = now
                        try rec.save(db)
                    }

                    for provider in payload.providers {
                        var rec = try ProviderRecord(from: provider)
                        rec.updatedAt = now
                        try rec.save(db)
                    }

                    for port in payload.portMappings {
                        let rec = PortMappingRecord(from: port)
                        try rec.save(db)
                    }

                case .duplicateAsNew:
                    let newWorkspaceId = UUID()
                    let newWorkspaceName = "\(payload.workspace.name) (Imported)"
                    ws = Workspace(
                        id: newWorkspaceId,
                        name: newWorkspaceName,
                        imagePath: payload.workspace.imagePath,
                        sortOrder: payload.workspace.sortOrder,
                        createdAt: now,
                        updatedAt: now
                    )
                    let wsRecord = WorkspaceRecord(from: ws)
                    try wsRecord.insert(db)

                    var groupIdMap: [UUID: UUID] = [:]
                    for group in payload.groups {
                        let newGroupId = UUID()
                        groupIdMap[group.id] = newGroupId
                        let newGroup = ServiceGroup(
                            id: newGroupId,
                            workspaceId: newWorkspaceId,
                            name: group.name,
                            sortOrder: group.sortOrder,
                            createdAt: now,
                            updatedAt: now
                        )
                        let rec = ServiceGroupRecord(from: newGroup)
                        try rec.insert(db)
                    }

                    var serviceIdMap: [UUID: UUID] = [:]
                    for service in payload.services {
                        let newServiceId = UUID()
                        serviceIdMap[service.id] = newServiceId
                        let mappedGroupId = service.groupId.flatMap { groupIdMap[$0] }
                        
                        let newService = Service(
                            id: newServiceId,
                            workspaceId: newWorkspaceId,
                            groupId: mappedGroupId,
                            name: service.name,
                            description: service.description,
                            isDisabled: service.isDisabled,
                            isFavorite: service.isFavorite,
                            activeProviderId: nil,
                            lastStatus: .stopped,
                            lastActivePort: nil,
                            sortOrder: service.sortOrder,
                            createdAt: now,
                            updatedAt: now
                        )
                        let rec = ServiceRecord(from: newService)
                        try rec.insert(db)
                    }

                    var providerIdMap: [UUID: UUID] = [:]
                    for provider in payload.providers {
                        guard let mappedServiceId = serviceIdMap[provider.serviceId] else { continue }
                        let newProviderId = UUID()
                        providerIdMap[provider.id] = newProviderId

                        let newProvider = Provider(
                            id: newProviderId,
                            serviceId: mappedServiceId,
                            label: provider.label,
                            config: provider.config,
                            kubeConfigId: provider.kubeConfigId,
                            createdAt: now,
                            updatedAt: now
                        )
                        let rec = try ProviderRecord(from: newProvider)
                        try rec.insert(db)
                    }

                    for service in payload.services {
                        guard let newServiceId = serviceIdMap[service.id],
                              let oldActiveProviderId = service.activeProviderId,
                              let newActiveProviderId = providerIdMap[oldActiveProviderId] else {
                            continue
                        }
                        try db.execute(
                            sql: "UPDATE services SET active_provider_id = ? WHERE id = ?",
                            arguments: [newActiveProviderId.uuidString, newServiceId.uuidString]
                        )
                    }

                    for port in payload.portMappings {
                        guard let mappedProviderId = providerIdMap[port.providerId] else { continue }
                        let newPort = PortMapping(
                            id: UUID(),
                            providerId: mappedProviderId,
                            localPort: port.localPort,
                            remotePort: port.remotePort,
                            protocolType: port.protocolType,
                            createdAt: now
                        )
                        let rec = PortMappingRecord(from: newPort)
                        try rec.insert(db)
                    }
                }

                createdWs = ws
                return .commit
            }

            guard let resultWs = createdWs else {
                throw DatabaseError(message: "Failed to resolve imported workspace after transaction commit.")
            }
            return resultWs
        }

        self.logger.info("Successfully imported workspace '\(importedWorkspace.name, privacy: .public)' (\(importedWorkspace.id)) with strategy: \(String(describing: strategy))")
        return importedWorkspace
    }
}
