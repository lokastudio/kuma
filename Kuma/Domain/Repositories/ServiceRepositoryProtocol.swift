//
//  ServiceRepositoryProtocol.swift
//  Kuma
//
//  Created for Task 3.4 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Domain protocol defining asynchronous CRUD and batch query operations for `Service`.
public protocol ServiceRepositoryProtocol: Sendable {
    /// Fetches all services belonging to a specific workspace ordered by sort order ascending and name ascending.
    func fetchServices(forWorkspaceId workspaceId: UUID) async throws -> [Service]
    
    /// Fetches all services belonging to a specific service group ordered by sort order ascending and name ascending.
    func fetchServices(forGroupId groupId: UUID) async throws -> [Service]
    
    /// Fetches all favorite services across all workspaces ordered by name ascending.
    func fetchFavoriteServices() async throws -> [Service]
    
    /// Fetches a single service by its unique ID.
    func fetchService(id: UUID) async throws -> Service?
    
    /// Inserts or updates a single service.
    func saveService(_ service: Service) async throws
    
    /// Inserts or updates multiple services in a single database transaction.
    func saveServices(_ services: [Service]) async throws
    
    /// Updates execution status and optional last active port for a specific service.
    func updateStatus(id: UUID, status: ServiceExecutionState, lastActivePort: Int?) async throws
    
    /// Updates the group assignment for a specific service.
    func updateGroup(serviceId: UUID, groupId: UUID?) async throws
    
    /// Updates sort order for multiple services in a single atomic database operation.
    func updateSortOrders(_ updates: [(id: UUID, sortOrder: Int)]) async throws
    
    /// Resets all services currently marked as starting or running back to stopped status (used on app boot restoration).
    func resetAllStatusesToStopped() async throws
    
    /// Deletes a service by its unique ID.
    func deleteService(id: UUID) async throws
}
