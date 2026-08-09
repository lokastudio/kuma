//
//  ProviderPayloads.swift
//  Kuma
//
//  Created for Task 2.2 in accordance with AGENTS.md & ROADMAP.md.
//

import Foundation

// MARK: - SSH Auth Method

/// Authentication method payload for SSH Tunnels.
public enum SSHAuthMethod: Codable, Sendable, Equatable, Hashable {
    case password
    case keyFile(path: String)
    case vaultReference(secretId: UUID)
}

// MARK: - Tunnel Provider Type

/// Public tunneling provider options.
public enum TunnelProviderType: String, Codable, Sendable, CaseIterable, Equatable, Hashable {
    case cloudflared
    case ngrok
}

// MARK: - Kube Port-Forward Payload

/// Payload configuration for Kubernetes Port-Forward provider.
public struct KubePortForwardPayload: Codable, Sendable, Equatable, Hashable {
    public var context: String
    public var namespace: String
    public var resourceType: String // e.g. "pod", "service", "deployment"
    public var resourceName: String
    public var kubeConfigId: UUID?
    
    public init(
        context: String,
        namespace: String = "default",
        resourceType: String = "service",
        resourceName: String,
        kubeConfigId: UUID? = nil
    ) {
        self.context = context
        self.namespace = namespace
        self.resourceType = resourceType
        self.resourceName = resourceName
        self.kubeConfigId = kubeConfigId
    }
}

// MARK: - Docker Compose Payload

/// Payload configuration for Docker Compose provider.
public struct DockerComposePayload: Codable, Sendable, Equatable, Hashable {
    public var projectDirectory: String
    public var composeFilePath: String?
    public var serviceName: String
    public var environmentVariables: [String: String]
    
    public init(
        projectDirectory: String,
        composeFilePath: String? = nil,
        serviceName: String,
        environmentVariables: [String: String] = [:]
    ) {
        self.projectDirectory = projectDirectory
        self.composeFilePath = composeFilePath
        self.serviceName = serviceName
        self.environmentVariables = environmentVariables
    }
}

// MARK: - Podman Compose Payload

/// Payload configuration for Podman Compose provider.
public struct PodmanComposePayload: Codable, Sendable, Equatable, Hashable {
    public var projectDirectory: String
    public var composeFilePath: String?
    public var serviceName: String
    public var environmentVariables: [String: String]
    
    public init(
        projectDirectory: String,
        composeFilePath: String? = nil,
        serviceName: String,
        environmentVariables: [String: String] = [:]
    ) {
        self.projectDirectory = projectDirectory
        self.composeFilePath = composeFilePath
        self.serviceName = serviceName
        self.environmentVariables = environmentVariables
    }
}

// MARK: - Shell Script Payload

/// Payload configuration for Shell Script provider.
public struct ShellScriptPayload: Codable, Sendable, Equatable, Hashable {
    public var command: String
    public var workingDirectory: String?
    public var environmentVariables: [String: String]
    
    public init(
        command: String,
        workingDirectory: String? = nil,
        environmentVariables: [String: String] = [:]
    ) {
        self.command = command
        self.workingDirectory = workingDirectory
        self.environmentVariables = environmentVariables
    }
}

// MARK: - SSH Tunnel Payload

/// Payload configuration for SSH Tunnel provider.
public struct SSHTunnelPayload: Codable, Sendable, Equatable, Hashable {
    public var host: String
    public var port: Int
    public var username: String
    public var authMethod: SSHAuthMethod
    public var remoteHost: String
    public var remotePort: Int
    
    public init(
        host: String,
        port: Int = 22,
        username: String,
        authMethod: SSHAuthMethod,
        remoteHost: String = "127.0.0.1",
        remotePort: Int
    ) {
        self.host = host
        self.port = port
        self.username = username
        self.authMethod = authMethod
        self.remoteHost = remoteHost
        self.remotePort = remotePort
    }
}

// MARK: - HTTP Check Payload

/// Payload configuration for HTTP Health Check provider.
public struct HTTPCheckPayload: Codable, Sendable, Equatable, Hashable {
    public var url: String
    public var expectedStatusCode: Int
    public var timeoutSeconds: Double
    public var checkIntervalSeconds: Double
    
    public init(
        url: String,
        expectedStatusCode: Int = 200,
        timeoutSeconds: Double = 5.0,
        checkIntervalSeconds: Double = 10.0
    ) {
        self.url = url
        self.expectedStatusCode = expectedStatusCode
        self.timeoutSeconds = timeoutSeconds
        self.checkIntervalSeconds = checkIntervalSeconds
    }
}

// MARK: - Tunnel Payload

/// Payload configuration for Public Tunnel provider (cloudflared / ngrok).
public struct TunnelPayload: Codable, Sendable, Equatable, Hashable {
    public var provider: TunnelProviderType
    public var localPort: Int
    public var hostname: String?
    
    public init(
        provider: TunnelProviderType = .cloudflared,
        localPort: Int,
        hostname: String? = nil
    ) {
        self.provider = provider
        self.localPort = localPort
        self.hostname = hostname
    }
}

// MARK: - Process Monitor Payload

/// Payload configuration for local Process Monitor provider.
public struct ProcessMonitorPayload: Codable, Sendable, Equatable, Hashable {
    public var processName: String?
    public var pidFile: String?
    public var checkIntervalSeconds: Double
    
    public init(
        processName: String? = nil,
        pidFile: String? = nil,
        checkIntervalSeconds: Double = 5.0
    ) {
        self.processName = processName
        self.pidFile = pidFile
        self.checkIntervalSeconds = checkIntervalSeconds
    }
}
