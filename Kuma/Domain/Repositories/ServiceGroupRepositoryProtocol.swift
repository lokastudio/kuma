//
//  ServiceGroupRepositoryProtocol.swift
//  Kuma
//
//  Created for Task 3.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Domain protocol defining asynchronous CRUD operations for `ServiceGroup`.
public protocol ServiceGroupRepositoryProtocol: Sendable {
    /// Fetches all service groups belonging to a specific workspace ordered by sort order ascending.
    func fetchServiceGroups(forWorkspaceId workspaceId: UUID) async throws -> [ServiceGroup]
    
    /// Fetches a single service group by its unique ID.
    func fetchServiceGroup(id: UUID) async throws -> ServiceGroup?
    
    /// Inserts or updates a single service group.
    func saveServiceGroup(_ group: ServiceGroup) async throws
    
    /// Inserts or updates multiple service groups in a single database transaction.
    func saveServiceGroups(_ groups: [ServiceGroup]) async throws
    
    /// Deletes a service group by its unique ID.
    func deleteServiceGroup(id: UUID) async throws
}
