//
//  DomainModelsTests.swift
//  KumaTests
//
//  Created for Task 2.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import XCTest
@testable import Kuma

final class DomainModelsTests: XCTestCase {
    
    func testWorkspaceInitializationAndCodable() throws {
        let workspace = Workspace(name: "E-Commerce Microservices", imagePath: "/avatars/ecommerce.png", sortOrder: 1)
        
        XCTAssertEqual(workspace.name, "E-Commerce Microservices")
        XCTAssertEqual(workspace.imagePath, "/avatars/ecommerce.png")
        XCTAssertEqual(workspace.sortOrder, 1)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(workspace)
        let decoder = JSONDecoder()
        let decodedWorkspace = try decoder.decode(Workspace.self, from: data)
        
        XCTAssertEqual(workspace, decodedWorkspace)
    }
    
    func testServiceGroupInitializationAndCodable() throws {
        let workspaceId = UUID()
        let group = ServiceGroup(workspaceId: workspaceId, name: "Daily Backend Stack")
        
        XCTAssertEqual(group.workspaceId, workspaceId)
        XCTAssertEqual(group.name, "Daily Backend Stack")
        
        let data = try JSONEncoder().encode(group)
        let decodedGroup = try JSONDecoder().decode(ServiceGroup.self, from: data)
        
        XCTAssertEqual(group, decodedGroup)
    }
    
    func testServiceInitializationAndCodable() throws {
        let workspaceId = UUID()
        let groupId = UUID()
        let service = Service(
            workspaceId: workspaceId,
            groupId: groupId,
            name: "PostgreSQL Database",
            description: "Primary transactional database",
            isFavorite: true,
            lastStatus: .running,
            lastActivePort: 5432
        )
        
        XCTAssertEqual(service.name, "PostgreSQL Database")
        XCTAssertEqual(service.lastStatus, .running)
        XCTAssertEqual(service.lastActivePort, 5432)
        XCTAssertTrue(service.isFavorite)
        
        let data = try JSONEncoder().encode(service)
        let decodedService = try JSONDecoder().decode(Service.self, from: data)
        
        XCTAssertEqual(service, decodedService)
    }
    
    func testProviderInitializationAndCodable() throws {
        let serviceId = UUID()
        let k8sPayload = KubePortForwardPayload(
            context: "gke_prod",
            namespace: "default",
            resourceType: "service",
            resourceName: "postgres-svc",
            remotePort: 5432
        )
        let provider = Provider(
            serviceId: serviceId,
            label: "GKE Staging",
            providerType: .kubePortForward,
            config: .kubePortForward(k8sPayload)
        )
        
        XCTAssertEqual(provider.serviceId, serviceId)
        XCTAssertEqual(provider.providerType, .kubePortForward)
        XCTAssertEqual(provider.config.summaryDescription, "service/postgres-svc (default)")
        
        let data = try JSONEncoder().encode(provider)
        let decodedProvider = try JSONDecoder().decode(Provider.self, from: data)
        
        XCTAssertEqual(provider, decodedProvider)
    }
    
    func testPortMappingInitializationAndCodable() throws {
        let providerId = UUID()
        let portMapping = PortMapping(providerId: providerId, localPort: 5432, remotePort: 5432)
        
        XCTAssertEqual(portMapping.providerId, providerId)
        XCTAssertEqual(portMapping.localPort, 5432)
        XCTAssertEqual(portMapping.remotePort, 5432)
        XCTAssertEqual(portMapping.protocolType, "tcp")
        
        let data = try JSONEncoder().encode(portMapping)
        let decodedPortMapping = try JSONDecoder().decode(PortMapping.self, from: data)
        
        XCTAssertEqual(portMapping, decodedPortMapping)
    }
    
    func testVaultSecretInitializationAndCodable() throws {
        let providerId = UUID()
        let secret = VaultSecret(
            providerId: providerId,
            secretType: .sshPassword,
            ciphertextBase64: "aW52YWxpZF9jaXBoZXJ0ZXh0",
            nonceBase64: "YWJjZGVmZ2hpamts"
        )
        
        XCTAssertEqual(secret.providerId, providerId)
        XCTAssertEqual(secret.secretType, .sshPassword)
        
        let data = try JSONEncoder().encode(secret)
        let decodedSecret = try JSONDecoder().decode(VaultSecret.self, from: data)
        
        XCTAssertEqual(secret, decodedSecret)
    }
    
    func testKubeConfigInitializationAndCodable() throws {
        let kubeConfig = KubeConfig(
            name: "Default KubeConfig",
            path: "~/.kube/config",
            isDefault: true
        )
        
        XCTAssertEqual(kubeConfig.name, "Default KubeConfig")
        XCTAssertEqual(kubeConfig.path, "~/.kube/config")
        XCTAssertTrue(kubeConfig.isDefault)
        
        let data = try JSONEncoder().encode(kubeConfig)
        let decodedKubeConfig = try JSONDecoder().decode(KubeConfig.self, from: data)
        
        XCTAssertEqual(kubeConfig, decodedKubeConfig)
    }
}
