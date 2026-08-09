//
//  ServiceGroupRepositoryTests.swift
//  KumaTests
//
//  Created for Task 3.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import XCTest
@testable import Kuma

final class ServiceGroupRepositoryTests: XCTestCase {

    var dbManager: DatabaseManager!
    var workspaceRepo: GRDBWorkspaceRepository!
    var groupRepo: GRDBServiceGroupRepository!

    override func setUpWithError() throws {
        dbManager = try DatabaseManager.makeInMemory()
        workspaceRepo = GRDBWorkspaceRepository(dbWriter: dbManager.dbWriter)
        groupRepo = GRDBServiceGroupRepository(dbWriter: dbManager.dbWriter)
    }

    override func tearDownWithError() throws {
        dbManager = nil
        workspaceRepo = nil
        groupRepo = nil
    }

    func testSaveAndFetchServiceGroup() async throws {
        let workspace = Workspace(name: "Test Workspace")
        try await workspaceRepo.saveWorkspace(workspace)

        let group = ServiceGroup(workspaceId: workspace.id, name: "Backend Services", sortOrder: 1)
        try await groupRepo.saveServiceGroup(group)

        let fetched = try await groupRepo.fetchServiceGroup(id: group.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.name, "Backend Services")
        XCTAssertEqual(fetched?.workspaceId, workspace.id)
    }

    func testFetchServiceGroupsForWorkspace() async throws {
        let ws1 = Workspace(name: "WS 1")
        let ws2 = Workspace(name: "WS 2")
        try await workspaceRepo.saveWorkspaces([ws1, ws2])

        let g1 = ServiceGroup(workspaceId: ws1.id, name: "Group B", sortOrder: 2)
        let g2 = ServiceGroup(workspaceId: ws1.id, name: "Group A", sortOrder: 1)
        let g3 = ServiceGroup(workspaceId: ws2.id, name: "Group C", sortOrder: 1)
        try await groupRepo.saveServiceGroups([g1, g2, g3])

        let ws1Groups = try await groupRepo.fetchServiceGroups(forWorkspaceId: ws1.id)
        XCTAssertEqual(ws1Groups.count, 2)
        XCTAssertEqual(ws1Groups[0].name, "Group A")
        XCTAssertEqual(ws1Groups[1].name, "Group B")

        let ws2Groups = try await groupRepo.fetchServiceGroups(forWorkspaceId: ws2.id)
        XCTAssertEqual(ws2Groups.count, 1)
        XCTAssertEqual(ws2Groups[0].name, "Group C")
    }

    func testDeleteServiceGroup() async throws {
        let workspace = Workspace(name: "Test Workspace")
        try await workspaceRepo.saveWorkspace(workspace)

        let group = ServiceGroup(workspaceId: workspace.id, name: "To Delete")
        try await groupRepo.saveServiceGroup(group)

        try await groupRepo.deleteServiceGroup(id: group.id)
        let fetched = try await groupRepo.fetchServiceGroup(id: group.id)
        XCTAssertNil(fetched)
    }

    func testCascadeDeleteFromWorkspace() async throws {
        let workspace = Workspace(name: "Parent Workspace")
        try await workspaceRepo.saveWorkspace(workspace)

        let group = ServiceGroup(workspaceId: workspace.id, name: "Child Group")
        try await groupRepo.saveServiceGroup(group)

        // Deleting workspace should cascade delete service group via SQLite foreign key
        try await workspaceRepo.deleteWorkspace(id: workspace.id)

        let fetchedGroup = try await groupRepo.fetchServiceGroup(id: group.id)
        XCTAssertNil(fetchedGroup)
    }
}
