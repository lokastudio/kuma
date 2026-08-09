//
//  ProviderConfig.swift
//  Kuma
//
//  Created for Task 2.2 in accordance with AGENTS.md & ROADMAP.md.
//

import Foundation

/// Type-safe polymorphic enum representing the execution configuration of a Provider.
/// Encapsulates the 8 execution provider engines in Kuma with strongly-typed associated value payloads.
/// Custom `Codable` implementation provides seamless JSON serialization for `providers.config_json` in SQLite.
public enum ProviderConfig: Codable, Sendable, Equatable, Hashable {
    case kubePortForward(KubePortForwardPayload)
    case dockerCompose(DockerComposePayload)
    case podmanCompose(PodmanComposePayload)
    case shellScript(ShellScriptPayload)
    case sshTunnel(SSHTunnelPayload)
    case httpCheck(HTTPCheckPayload)
    case tunnel(TunnelPayload)
    case processMonitor(ProcessMonitorPayload)
    
    // MARK: - Domain Attributes
    
    /// The string discriminator matching `ProviderType`.
    public nonisolated var providerType: ProviderType {
        switch self {
        case .kubePortForward:
            return .kubePortForward
        case .dockerCompose:
            return .docker
        case .podmanCompose:
            return .podman
        case .shellScript:
            return .shell
        case .sshTunnel:
            return .ssh
        case .httpCheck:
            return .httpCheck
        case .tunnel:
            return .tunnel
        case .processMonitor:
            return .processMonitor
        }
    }
    
    /// Human-readable display name for UI presentation.
    public var displayName: String {
        providerType.displayName
    }
    
    /// A concise summary description of the configuration settings.
    public var summaryDescription: String {
        switch self {
        case .kubePortForward(let payload):
            return "\(payload.resourceType)/\(payload.resourceName) (\(payload.namespace))"
        case .dockerCompose(let payload):
            return "Compose: \(payload.serviceName)"
        case .podmanCompose(let payload):
            return "Podman: \(payload.serviceName)"
        case .shellScript(let payload):
            return payload.command
        case .sshTunnel(let payload):
            return "\(payload.username)@\(payload.host):\(payload.port) ➔ \(payload.remoteHost):\(payload.remotePort)"
        case .httpCheck(let payload):
            return payload.url
        case .tunnel(let payload):
            return "\(payload.provider.rawValue.capitalized) ➔ Port \(payload.localPort)"
        case .processMonitor(let payload):
            if let name = payload.processName {
                return "Process: \(name)"
            } else if let pidFile = payload.pidFile {
                return "PID File: \(pidFile)"
            } else {
                return "Process Monitor"
            }
        }
    }
    
    // MARK: - Custom Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case type
        case payload
    }
    
    public nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ProviderType.self, forKey: .type)
        
        switch type {
        case .kubePortForward:
            let payload = try container.decode(KubePortForwardPayload.self, forKey: .payload)
            self = .kubePortForward(payload)
        case .docker:
            let payload = try container.decode(DockerComposePayload.self, forKey: .payload)
            self = .dockerCompose(payload)
        case .podman:
            let payload = try container.decode(PodmanComposePayload.self, forKey: .payload)
            self = .podmanCompose(payload)
        case .shell:
            let payload = try container.decode(ShellScriptPayload.self, forKey: .payload)
            self = .shellScript(payload)
        case .ssh:
            let payload = try container.decode(SSHTunnelPayload.self, forKey: .payload)
            self = .sshTunnel(payload)
        case .httpCheck:
            let payload = try container.decode(HTTPCheckPayload.self, forKey: .payload)
            self = .httpCheck(payload)
        case .tunnel:
            let payload = try container.decode(TunnelPayload.self, forKey: .payload)
            self = .tunnel(payload)
        case .processMonitor:
            let payload = try container.decode(ProcessMonitorPayload.self, forKey: .payload)
            self = .processMonitor(payload)
        }
    }
    
    public nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(providerType, forKey: .type)
        
        switch self {
        case .kubePortForward(let payload):
            try container.encode(payload, forKey: .payload)
        case .dockerCompose(let payload):
            try container.encode(payload, forKey: .payload)
        case .podmanCompose(let payload):
            try container.encode(payload, forKey: .payload)
        case .shellScript(let payload):
            try container.encode(payload, forKey: .payload)
        case .sshTunnel(let payload):
            try container.encode(payload, forKey: .payload)
        case .httpCheck(let payload):
            try container.encode(payload, forKey: .payload)
        case .tunnel(let payload):
            try container.encode(payload, forKey: .payload)
        case .processMonitor(let payload):
            try container.encode(payload, forKey: .payload)
        }
    }
}
