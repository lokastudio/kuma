//
//  SettingsTab.swift
//  Kuma
//
//  Created for Task 7.8 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import Foundation

/// Tabs presented in `SettingsView`.
public enum SettingsTab: String, CaseIterable, Identifiable, Sendable {
    case general = "General"
    case startup = "Startup"
    case kubeconfig = "Kubernetes"

    public var id: String { rawValue }

    public var systemImage: String {
        switch self {
        case .general:
            return "gearshape"
        case .startup:
            return "bolt.horizontal"
        case .kubeconfig:
            return "shippingbox"
        }
    }
}
