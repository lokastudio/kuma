//
//  KumaLogger.swift
//  Kuma
//
//  Unified os.Logger (OSLog) Categories for Kuma Native macOS App.
//  Strictly prohibits raw print() in production code.
//

import Foundation
import os

public enum KumaLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.personal.kuma"
    
    /// Unified logger for app lifecycle and window coordinator events
    public static let appLifecycle = Logger(subsystem: subsystem, category: "AppLifecycle")
    
    /// Unified logger for process execution, orphan killing, and system engine events
    public static let processEngine = Logger(subsystem: subsystem, category: "ProcessEngine")
    
    /// Unified logger for GRDB database operations, migrations, and secrets vault
    public static let database = Logger(subsystem: subsystem, category: "Database")
    
    /// Unified logger for SwiftUI presentation, navigation, and user interactions
    public static let ui = Logger(subsystem: subsystem, category: "Presentation")
}
