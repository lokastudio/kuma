import XCTest
@testable import Kuma

final class WorkspaceTests: XCTestCase {
    
    func testWorkspaceInitializationAndDefaultName() {
        let id = UUID()
        let now = Date()
        
        let workspace = Workspace(
            id: id,
            name: "Development",
            imagePath: "/tmp/avatar.png",
            createdAt: now,
            updatedAt: now
        )
        
        XCTAssertEqual(workspace.id, id)
        XCTAssertEqual(workspace.name, "Development")
        XCTAssertEqual(workspace.imagePath, "/tmp/avatar.png")
        
        // Test extension defaultName returns non-empty string
        XCTAssertFalse(Workspace.defaultName.isEmpty)
        XCTAssertTrue(Workspace.defaultName.contains("Space"))
    }
}
