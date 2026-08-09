//
//  WorkspaceStore.swift
//  Kuma
//
//  Created for Task 6.2 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import AppKit
import Foundation
import Observation
import os

/// `@Observable` manager for Workspace environments, navigation state, and safe workspace switching.
@MainActor
@Observable
public final class WorkspaceStore {
    private static let logger = Logger(subsystem: "lokastudio.kuma", category: "WorkspaceStore")

    // MARK: - State Properties

    public private(set) var workspaces: [Workspace] = []
    public var activeWorkspaceId: UUID?
    public var isSwitchConfirmationPresented: Bool = false
    public private(set) var pendingWorkspaceSwitchId: UUID?
    public private(set) var isLoading: Bool = false
    public var errorMessage: String?

    private let repository: WorkspaceRepositoryProtocol

    // MARK: - Computed Properties

    public var activeWorkspace: Workspace? {
        guard let id = activeWorkspaceId else { return workspaces.first }
        return workspaces.first(where: { $0.id == id }) ?? workspaces.first
    }

    // MARK: - Initialization

    public init(repository: WorkspaceRepositoryProtocol) {
        self.repository = repository
        Self.logger.debug("WorkspaceStore initialized")
    }

    // MARK: - Workspace Operations

    public func loadWorkspaces() async {
        isLoading = true
        errorMessage = nil
        do {
            workspaces = try await repository.fetchWorkspaces()
            if activeWorkspaceId == nil || !workspaces.contains(where: { $0.id == activeWorkspaceId }) {
                activeWorkspaceId = workspaces.first?.id
            }
            Self.logger.info("Loaded \(self.workspaces.count, privacy: .public) workspaces")
        } catch {
            errorMessage = "Failed to load workspaces: \(error.localizedDescription)"
            Self.logger.error("Failed to load workspaces: \(error.localizedDescription, privacy: .public)")
        }
        isLoading = false
    }

    public func selectWorkspace(id: UUID, hasActiveServices: Bool) {
        guard id != activeWorkspaceId else { return }
        if hasActiveServices {
            pendingWorkspaceSwitchId = id
            isSwitchConfirmationPresented = true
            Self.logger.info("Requesting safe switch confirmation for workspace ID: \(id)")
        } else {
            activeWorkspaceId = id
            Self.logger.info("Switched to workspace ID: \(id)")
        }
    }

    public func confirmWorkspaceSwitch(stopServicesHandler: () async throws -> Void) async {
        guard let targetId = pendingWorkspaceSwitchId else { return }
        Self.logger.info("Stopping active services and switching to workspace ID: \(targetId)")
        do {
            try await stopServicesHandler()
            activeWorkspaceId = targetId
            pendingWorkspaceSwitchId = nil
            isSwitchConfirmationPresented = false
        } catch {
            errorMessage = "Failed to stop services before switching: \(error.localizedDescription)"
            Self.logger.error("Failed to stop active services during workspace switch: \(error.localizedDescription, privacy: .public)")
        }
    }

    public func cancelWorkspaceSwitch() {
        pendingWorkspaceSwitchId = nil
        isSwitchConfirmationPresented = false
    }

    public func clearErrorMessage() {
        errorMessage = nil
    }

    public func createWorkspace(name: String, imagePath: String? = nil) async {
        let newWorkspace = Workspace(
            name: name,
            imagePath: imagePath,
            sortOrder: workspaces.count
        )
        do {
            try await repository.saveWorkspace(newWorkspace)
            workspaces.append(newWorkspace)
            activeWorkspaceId = newWorkspace.id
            Self.logger.info("Created workspace: \(name, privacy: .public)")
        } catch {
            errorMessage = "Failed to create workspace: \(error.localizedDescription)"
            Self.logger.error("Failed to create workspace: \(error.localizedDescription, privacy: .public)")
        }
    }

    public func updateWorkspace(_ workspace: Workspace) async {
        do {
            try await repository.saveWorkspace(workspace)
            if let idx = workspaces.firstIndex(where: { $0.id == workspace.id }) {
                workspaces[idx] = workspace
            }
            Self.logger.info("Updated workspace: \(workspace.name, privacy: .public)")
        } catch {
            errorMessage = "Failed to update workspace: \(error.localizedDescription)"
            Self.logger.error("Failed to update workspace: \(error.localizedDescription, privacy: .public)")
        }
    }

    public func deleteWorkspace(id: UUID) async {
        do {
            try await repository.deleteWorkspace(id: id)
            workspaces.removeAll(where: { $0.id == id })
            if activeWorkspaceId == id {
                activeWorkspaceId = workspaces.first?.id
            }
            Self.logger.info("Deleted workspace ID: \(id)")
        } catch {
            errorMessage = "Failed to delete workspace: \(error.localizedDescription)"
            Self.logger.error("Failed to delete workspace: \(error.localizedDescription, privacy: .public)")
        }
    }

    public func reorderWorkspaces(_ newOrder: [Workspace]) async {
        var updated = newOrder
        for i in 0..<updated.count {
            updated[i].sortOrder = i
        }
        do {
            try await repository.saveWorkspaces(updated)
            workspaces = updated
            Self.logger.info("Reordered \(updated.count, privacy: .public) workspaces")
        } catch {
            errorMessage = "Failed to reorder workspaces: \(error.localizedDescription)"
            Self.logger.error("Failed to reorder workspaces: \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: - Avatar Image Loading

    public func avatarImage(for path: String?, maxDimension: CGFloat = 64) -> NSImage? {
        guard let path, !path.isEmpty else { return nil }
        let url = URL(fileURLWithPath: path)
        return WorkspaceImageStore.shared.thumbnail(for: url, maxDimension: maxDimension)
    }

    // MARK: - Mock for Previews & Tests

    public static var mock: WorkspaceStore {
        let mockWorkspaces = [
            Workspace(name: "Default Workspace", sortOrder: 0),
            Workspace(name: "Staging Stack", sortOrder: 1),
            Workspace(name: "Production Ops", sortOrder: 2)
        ]
        let repo = MockWorkspaceRepository(workspaces: mockWorkspaces)
        let store = WorkspaceStore(repository: repo)
        store.workspaces = mockWorkspaces
        store.activeWorkspaceId = mockWorkspaces.first?.id
        return store
    }
}

// MARK: - Mock Repository Helper

private final class MockWorkspaceRepository: WorkspaceRepositoryProtocol, @unchecked Sendable {
    var workspaces: [Workspace]
    init(workspaces: [Workspace] = []) { self.workspaces = workspaces }
    func fetchWorkspaces() async throws -> [Workspace] { workspaces }
    func fetchWorkspace(id: UUID) async throws -> Workspace? { workspaces.first(where: { $0.id == id }) }
    func saveWorkspace(_ workspace: Workspace) async throws {
        if let idx = workspaces.firstIndex(where: { $0.id == workspace.id }) {
            workspaces[idx] = workspace
        } else {
            workspaces.append(workspace)
        }
    }
    func saveWorkspaces(_ workspaces: [Workspace]) async throws { self.workspaces = workspaces }
    func deleteWorkspace(id: UUID) async throws { workspaces.removeAll(where: { $0.id == id }) }
}
