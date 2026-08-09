import XCTest
@testable import Kuma

struct MockKubeConfigRepository: KubeConfigRepositoryProtocol {
    var kubeConfigs: [KubeConfig] = []

    func fetchKubeConfigs() async throws -> [KubeConfig] {
        return kubeConfigs
    }

    func fetchKubeConfig(id: UUID) async throws -> KubeConfig? {
        return kubeConfigs.first(where: { $0.id == id })
    }

    func saveKubeConfig(_ kubeConfig: KubeConfig) async throws {
        // Mock save
    }

    func deleteKubeConfig(id: UUID) async throws {
        // Mock delete
    }

    func setDefaultKubeConfig(id: UUID) async throws {
        // Mock set default
    }
}

@MainActor
final class KubeConfigStoreTests: XCTestCase {
    var repository: MockKubeConfigRepository!
    var store: KubeConfigStore!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        repository = MockKubeConfigRepository()
        store = KubeConfigStore(repository: repository)
    }
    
    override func tearDownWithError() throws {
        repository = nil
        store = nil
        try super.tearDownWithError()
    }
    
    func testLoadKubeConfigs() async throws {
        let sampleConfig = KubeConfig(name: "Default Config", path: "~/.kube/config", isDefault: true)
        repository.kubeConfigs = [sampleConfig]
        
        await store.loadKubeConfigs()
        XCTAssertEqual(store.kubeConfigs.count, 1)
        XCTAssertEqual(store.defaultKubeConfig?.name, "Default Config")
    }

    func testRegisterKubeConfig() async throws {
        await store.registerKubeConfig(name: "Staging Cluster", path: "/tmp/staging.yaml", isDefault: false)
        XCTAssertNil(store.errorMessage)
    }
}

