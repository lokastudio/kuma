import XCTest
@testable import Kuma

final class ProviderTypeTests: XCTestCase {
    
    func testProviderTypeRawValuesAndDisplayNames() {
        XCTAssertEqual(ProviderType.kubePortForward.rawValue, "kube_port_forward")
        XCTAssertEqual(ProviderType.kubePortForward.name, "Kubernetes Port-Forward")
        
        XCTAssertEqual(ProviderType.docker.rawValue, "docker")
        XCTAssertEqual(ProviderType.docker.name, "Docker Compose")
        
        XCTAssertEqual(ProviderType.podman.rawValue, "podman")
        XCTAssertEqual(ProviderType.podman.name, "Podman Compose")
        
        XCTAssertEqual(ProviderType.shell.rawValue, "shell")
        XCTAssertEqual(ProviderType.shell.name, "Shell Script")
        
        XCTAssertEqual(ProviderType.ssh.rawValue, "ssh")
        XCTAssertEqual(ProviderType.ssh.name, "SSH Connection")
        
        XCTAssertEqual(ProviderType.httpCheck.rawValue, "http_check")
        XCTAssertEqual(ProviderType.httpCheck.name, "HTTP Health Check")
        
        XCTAssertEqual(ProviderType.tunnel.rawValue, "tunnel")
        XCTAssertEqual(ProviderType.tunnel.name, "Public Tunnel")
        
        XCTAssertEqual(ProviderType.processMonitor.rawValue, "process_monitor")
        XCTAssertEqual(ProviderType.processMonitor.name, "Process Monitor")
    }
    
    func testAllCasesCount() {
        XCTAssertEqual(ProviderType.allCases.count, 8)
    }
}
