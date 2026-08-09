//
//  WorkspaceRepositoryProtocol.swift
//  Kuma
//
//  Created for Task 3.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Domain protocol defining asynchronous CRUD operations for `Workspace`.
public protocol WorkspaceRepositoryProtocol: Sendable {
    /// Fetches all workspaces ordered by sort order ascending.
    func fetchWorkspaces() async throws -> [Workspace]
    
    /// Fetches a single workspace by its unique ID.
    func fetchWorkspace(id: UUID) async throws -> Workspace?
    
    /// Inserts or updates a single workspace.
    func saveWorkspace(_ workspace: Workspace) async throws
    
    /// Inserts or updates multiple workspaces in a single database transaction.
    func saveWorkspaces(_ workspaces: [Workspace]) async throws
    
    /// Deletes a workspace by its unique ID. Cascades to associated service groups and services.
    func deleteWorkspace(id: UUID) async throws
}
