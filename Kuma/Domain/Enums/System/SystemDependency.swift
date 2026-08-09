//
//  SystemDependency.swift
//  Kuma
//
//  Created for Task 2.4 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Pure domain enum representing system binary/tool dependencies required by providers or execution state checks.
public enum SystemDependency: Codable, Sendable, Equatable, Hashable, Identifiable {
    case kubectl
    case docker
    case podman
    case cloudflared
    case ngrok
    case ssh
    case custom(binaryName: String)

    public var id: String {
        switch self {
        case .kubectl: return "kubectl"
        case .docker: return "docker"
        case .podman: return "podman"
        case .cloudflared: return "cloudflared"
        case .ngrok: return "ngrok"
        case .ssh: return "ssh"
        case .custom(let binaryName): return "custom-\(binaryName)"
        }
    }

    /// Primary CLI executable binary name.
    public var executableName: String {
        switch self {
        case .kubectl: return "kubectl"
        case .docker: return "docker"
        case .podman: return "podman"
        case .cloudflared: return "cloudflared"
        case .ngrok: return "ngrok"
        case .ssh: return "ssh"
        case .custom(let binaryName): return binaryName
        }
    }

    /// User-friendly display name.
    public var displayName: String {
        switch self {
        case .kubectl: return "Kubectl CLI"
        case .docker: return "Docker Engine"
        case .podman: return "Podman CLI"
        case .cloudflared: return "Cloudflare Tunnel (cloudflared)"
        case .ngrok: return "Ngrok Tunnel (ngrok)"
        case .ssh: return "OpenSSH Client"
        case .custom(let binaryName): return binaryName
        }
    }

    /// Suggested Homebrew / installation hint for Mac users.
    public var installHint: String? {
        switch self {
        case .kubectl: return "brew install kubernetes-cli"
        case .docker: return "brew install --cask docker"
        case .podman: return "brew install podman"
        case .cloudflared: return "brew install cloudflared"
        case .ngrok: return "brew install ngrok"
        case .ssh: return nil
        case .custom: return nil
        }
    }
}
