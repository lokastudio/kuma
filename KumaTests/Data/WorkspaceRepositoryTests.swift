//
//  WorkspaceRepositoryTests.swift
//  KumaTests
//
//  Created for Task 3.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import XCTest
@testable import Kuma

final class WorkspaceRepositoryTests: XCTestCase {

    var dbManager: DatabaseManager!
    var repository: GRDBWorkspaceRepository!

    override func setUpWithError() throws {
        dbManager = try DatabaseManager.makeInMemory()
        repository = GRDBWorkspaceRepository(dbWriter: dbManager.dbWriter)
    }

    override func tearDownWithError() throws {
        dbManager = nil
        repository = nil
    }

    func testSaveAndFetchWorkspace() async throws {
        let workspace = Workspace(name: "Default Workspace", sortOrder: 1)
        try await repository.saveWorkspace(workspace)

        let fetched = try await repository.fetchWorkspace(id: workspace.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.name, "Default Workspace")
        XCTAssertEqual(fetched?.sortOrder, 1)
    }

    func testFetchAllWorkspacesOrdered() async throws {
        let ws1 = Workspace(name: "Beta Workspace", sortOrder: 2)
        let ws2 = Workspace(name: "Alpha Workspace", sortOrder: 1)
        try await repository.saveWorkspaces([ws1, ws2])

        let all = try await repository.fetchWorkspaces()
        XCTAssertEqual(all.count, 2)
        XCTAssertEqual(all[0].name, "Alpha Workspace")
        XCTAssertEqual(all[1].name, "Beta Workspace")
    }

    func testUpdateWorkspace() async throws {
        var workspace = Workspace(name: "Original Name")
        try await repository.saveWorkspace(workspace)

        workspace.name = "Updated Name"
        try await repository.saveWorkspace(workspace)

        let fetched = try await repository.fetchWorkspace(id: workspace.id)
        XCTAssertEqual(fetched?.name, "Updated Name")
    }

    func testDeleteWorkspace() async throws {
        let workspace = Workspace(name: "To Delete")
        try await repository.saveWorkspace(workspace)

        try await repository.deleteWorkspace(id: workspace.id)
        let fetched = try await repository.fetchWorkspace(id: workspace.id)
        XCTAssertNil(fetched)
    }
}
