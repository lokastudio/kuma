//
//  ProviderType.swift
//  Kuma
//
//  Created for Task 2.2 in accordance with AGENTS.md & ROADMAP.md.
//

import Foundation

/// Discriminator enum representing the type of execution provider in Kuma.
/// Matches `providers.provider_type` in SQLite database.
public enum ProviderType: String, Codable, Sendable, CaseIterable, Equatable, Hashable {
    case kubePortForward = "kube_port_forward"
    case docker = "docker"
    case podman = "podman"
    case shell = "shell"
    case ssh = "ssh"
    case httpCheck = "http_check"
    case tunnel = "tunnel"
    case processMonitor = "process_monitor"
    
    // MARK: - UI Presentation Attributes
    
    /// Display name for presentation layer.
    public var displayName: String {
        switch self {
        case .kubePortForward:
            return "Kubernetes Port-Forward"
        case .docker:
            return "Docker Compose"
        case .podman:
            return "Podman Compose"
        case .shell:
            return "Shell Script"
        case .ssh:
            return "SSH Tunnel"
        case .httpCheck:
            return "HTTP Health Check"
        case .tunnel:
            return "Public Tunnel"
        case .processMonitor:
            return "Process Monitor"
        }
    }
    
    /// SF Symbol icon name.
    public var systemImage: String {
        switch self {
        case .kubePortForward:
            return "shippingbox"
        case .docker:
            return "container.training"
        case .podman:
            return "shippingbox.circle"
        case .shell:
            return "terminal"
        case .ssh:
            return "network"
        case .httpCheck:
            return "globe"
        case .tunnel:
            return "arrow.triangle.pull"
        case .processMonitor:
            return "cpu"
        }
    }
    
    /// Accent color token identifier matching `AGENTS.md` Provider Tints:
    /// K8s = `.blue`, Docker = `.cyan`, Podman = `.purple`, Shell = `.orange`.
    public var accentColorName: String {
        switch self {
        case .kubePortForward:
            return "blue"
        case .docker:
            return "cyan"
        case .podman:
            return "purple"
        case .shell:
            return "orange"
        case .ssh:
            return "indigo"
        case .httpCheck:
            return "green"
        case .tunnel:
            return "teal"
        case .processMonitor:
            return "mint"
        }
    }
}
