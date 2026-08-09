//
//  SingleInstanceHelper.swift
//  Kuma
//
//  Single Instance Guard enforcing macOS 14+ activate() API.
//  Deprecated activateIgnoringOtherApps is strictly forbidden.
//

import AppKit
import Foundation
import os

public struct SingleInstanceHelper {
    /// Ensures only a single instance of Kuma is active.
    /// If another instance is running, brings it to focus and returns false.
    @MainActor
    public static func checkAndEnforceSingleInstance(bundleIdentifier: String) -> Bool {
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
        
        let otherApps = runningApps.filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
        
        if let existingApp = otherApps.first {
            KumaLogger.appLifecycle.notice("Another instance of Kuma is already running (PID: \(existingApp.processIdentifier)). Activating existing instance.")
            existingApp.activate()
            return false
        }
        
        return true
    }
}
