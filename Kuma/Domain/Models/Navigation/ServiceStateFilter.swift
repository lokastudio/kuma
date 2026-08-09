//
//  ServiceStateFilter.swift
//  Kuma
//
//  Created for Task 7.5 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import Foundation

/// Filter options for service execution status in `ServicesDeckView`.
public enum ServiceStateFilter: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case running = "Running"
    case stopped = "Stopped"
    case failed = "Failed"

    public var id: String { rawValue }
}
