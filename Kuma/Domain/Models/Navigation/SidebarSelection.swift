//
//  SidebarSelection.swift
//  Kuma
//
//  Created for Task 7.4 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import Foundation

/// Navigation destination choices for `SidebarView`.
public enum SidebarSelection: Hashable, Sendable, Codable {
    case allRunning
    case allServices
    case provider(ProviderType)
    case customGroup(UUID)
    case settings
    case help

    /// Human-readable label for navigation headers.
    public var title: String {
        switch self {
        case .allRunning:
            return "Active Services"
        case .allServices:
            return "All Services"
        case .provider(let type):
            return type.displayName
        case .customGroup:
            return "Custom Group"
        case .settings:
            return "Settings"
        case .help:
            return "Help & Guide"
        }
    }
}
