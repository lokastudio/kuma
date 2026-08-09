import XCTest
import GRDB
@testable import Kuma

@MainActor
final class WorkspaceStoreTests: XCTestCase {
    var dbQueue: DatabaseQueue!
    var repository: WorkspaceRepository!
    var imageStore: WorkspaceImageStore!
    var store: WorkspaceStore!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        dbQueue = try DatabaseManager(inMemory: true).dbQueue
        repository = WorkspaceRepository(dbQueue: dbQueue)
        imageStore = WorkspaceImageStore.shared
        store = WorkspaceStore(repository: repository, imageStore: imageStore)
    }
    
    override func tearDownWithError() throws {
        dbQueue = nil
        repository = nil
        imageStore = nil
        store = nil
        try super.tearDownWithError()
    }
    
    func testLoadWorkspacesFromInDatabase() async throws {
        // Fresh database starts with 1 default workspace from migration v2
        await store.loadWorkspaces()
        XCTAssertGreaterThanOrEqual(store.workspaces.count, 1)
        
        let initialCount = store.workspaces.count
        let ws1 = Workspace(id: UUID(), name: "Custom Space", imagePath: nil, createdAt: Date(), updatedAt: Date())
        try await repository.insert(ws1)
        
        await store.loadWorkspaces()
        XCTAssertEqual(store.workspaces.count, initialCount + 1)
    }
    
    func testCreateWorkspaceValidation() async throws {
        do {
            _ = try await store.createWorkspace(name: "   ")
            XCTFail("Should fail with empty workspace name")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains("cannot be empty"))
        }
        
        await store.loadWorkspaces()
        let countBefore = store.workspaces.count
        
        let created = try await store.createWorkspace(name: "New Project")
        XCTAssertEqual(created.name, "New Project")
        XCTAssertEqual(store.workspaces.count, countBefore + 1)
    }
    
    func testDeleteWorkspaceValidation() async throws {
        await store.loadWorkspaces()
        
        // Delete all except 1
        while store.workspaces.count > 1 {
            if let lastID = store.workspaces.last?.id {
                try await store.deleteWorkspace(id: lastID)
            }
        }
        
        // Cannot delete sole remaining workspace
        if let soleID = store.workspaces.first?.id {
            do {
                try await store.deleteWorkspace(id: soleID)
                XCTFail("Should not allow deleting the last workspace")
            } catch {
                XCTAssertTrue(error.localizedDescription.contains("At least one workspace must remain"))
            }
        }
        
        let created = try await store.createWorkspace(name: "Extra Space")
        XCTAssertEqual(store.workspaces.count, 2)
        
        // Can delete when 2 workspaces exist
        try await store.deleteWorkspace(id: created.id)
        XCTAssertEqual(store.workspaces.count, 1)
    }
}
