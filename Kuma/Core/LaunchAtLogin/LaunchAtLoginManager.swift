//
//  LaunchAtLoginManager.swift
//  Kuma
//
//  Created for Task 7.8 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import Foundation
import ServiceManagement
import os

/// Helper manager wrapping macOS 14+ `SMAppService.mainApp` for Launch at Login functionality.
@MainActor
public final class LaunchAtLoginManager {
    private static let logger = Logger(subsystem: "lokastudio.kuma", category: "LaunchAtLoginManager")

    public static let shared = LaunchAtLoginManager()

    private init() {}

    /// Current registration status of Launch at Login service.
    public var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    /// Enables or disables Launch at Login via `SMAppService.mainApp`.
    public func setEnabled(_ enabled: Bool) throws {
        let service = SMAppService.mainApp
        if enabled {
            if service.status != .enabled {
                try service.register()
                Self.logger.info("Successfully registered mainApp for Launch at Login.")
            }
        } else {
            if service.status == .enabled {
                try service.unregister()
                Self.logger.info("Successfully unregistered mainApp from Launch at Login.")
            }
        }
    }
}
