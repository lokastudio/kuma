//
//  DatabaseManager.swift
//  Kuma
//
//  Created for Kuma Task 3.1.
//  Governance & Concurrency: Swift 6 Strict Concurrency, GRDB DatabaseWriter/DatabaseQueue, os.Logger.
//

import Foundation
import GRDB
import os

/// Thread-safe manager responsible for initializing and serving GRDB database access.
public final class DatabaseManager: Sendable {
    
    // MARK: - Properties
    
    /// Thread-safe GRDB database writer instance (DatabaseQueue or DatabasePool).
    public let dbWriter: any DatabaseWriter
    
    /// Native structured logger for database activities.
    private static let logger = Logger(subsystem: "com.kuma.app", category: "Database")
    
    // MARK: - Initializers
    
    /// Initializes `DatabaseManager` with a provided `DatabaseWriter`.
    /// - Parameter dbWriter: GRDB DatabaseWriter instance.
    public init(dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
    }
    
    /// Creates a `DatabaseManager` backed by a file at the standard Application Support path or a custom path.
    /// - Parameter customPath: Optional custom file URL. If nil, uses `~/Library/Application Support/Kuma/kuma.sqlite`.
    /// - Returns: Initialized `DatabaseManager`.
    public static func makePersistent(at customPath: URL? = nil) throws -> DatabaseManager {
        let fileURL: URL
        if let customPath {
            fileURL = customPath
        } else {
            let appSupport = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let kumaDir = appSupport.appendingPathComponent("Kuma", isDirectory: true)
            if !FileManager.default.fileExists(atPath: kumaDir.path) {
                try FileManager.default.createDirectory(at: kumaDir, withIntermediateDirectories: true)
            }
            fileURL = kumaDir.appendingPathComponent("kuma.sqlite")
        }
        
        var config = Configuration()
        config.label = "com.kuma.database"
        config.qos = .userInitiated
        #if DEBUG
        config.publicStatementArguments = true
        #endif
        config.prepareDatabase { db in
            try db.execute(sql: "PRAGMA foreign_keys = ON;")
            try db.execute(sql: "PRAGMA journal_mode = WAL;")
            try db.execute(sql: "PRAGMA synchronous = NORMAL;")
        }
        
        logger.info("Initializing persistent SQLite database at: \(fileURL.path, privacy: .public)")
        let dbQueue = try DatabaseQueue(path: fileURL.path, configuration: config)
        
        var migrator = DatabaseMigrator()
        V1SchemaMigration.register(on: &migrator)
        try migrator.migrate(dbQueue)
        
        return DatabaseManager(dbWriter: dbQueue)
    }
    
    /// Creates an in-memory `DatabaseManager` for unit tests and SwiftUI `#Preview`.
    /// - Returns: In-memory `DatabaseManager`.
    public static func makeInMemory() throws -> DatabaseManager {
        var config = Configuration()
        config.label = "com.kuma.database.inmemory"
        config.prepareDatabase { db in
            try db.execute(sql: "PRAGMA foreign_keys = ON;")
        }
        
        logger.info("Initializing in-memory SQLite database for testing/preview")
        let dbQueue = try DatabaseQueue(configuration: config)
        
        var migrator = DatabaseMigrator()
        V1SchemaMigration.register(on: &migrator)
        try migrator.migrate(dbQueue)
        
        return DatabaseManager(dbWriter: dbQueue)
    }
}
