//
//  JSONImporter.swift
//  Kuma
//
//  Created for Task 4.6 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation
import os

/// Custom errors thrown during workspace JSON import validation or decoding.
public enum JSONImporterError: Error, LocalizedError, Sendable {
    case fileNotFound(URL)
    case unreadableData(Error)
    case invalidSchemaVersion(String)
    case decodingFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let url):
            return "Workspace configuration file not found at \(url.path)."
        case .unreadableData(let err):
            return "Failed to read file data: \(err.localizedDescription)"
        case .invalidSchemaVersion(let version):
            return "Unsupported schema version '\(version)'. Please update Kuma to import this workspace."
        case .decodingFailed(let err):
            return "Failed to decode workspace JSON: \(err.localizedDescription)"
        }
    }
}

/// Thread-safe parser & validator converting raw JSON data into `WorkspaceExportPayload`.
public final class JSONImporter: Sendable {

    private let logger = Logger(subsystem: "com.kuma.app", category: "Database")
    private let jsonDecoder: JSONDecoder

    public init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
        self.jsonDecoder.dateDecodingStrategy = .iso8601
    }

    /// Decode and validate a `WorkspaceExportPayload` from raw Data.
    public func decodePayload(from data: Data) throws -> WorkspaceExportPayload {
        do {
            let payload = try jsonDecoder.decode(WorkspaceExportPayload.self, from: data)
            logger.debug("Successfully decoded workspace export payload: \(payload.workspace.name, privacy: .public)")
            return payload
        } catch {
            // Check if failure was due to unsupported schema version string
            if let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let versionStr = jsonObj["version"] as? String,
               ExportPayloadVersion(rawValue: versionStr) == nil {
                logger.error("Unsupported workspace schema version: \(versionStr, privacy: .public)")
                throw JSONImporterError.invalidSchemaVersion(versionStr)
            }
            
            logger.error("JSONImporter decoding error: \(error.localizedDescription, privacy: .public)")
            throw JSONImporterError.decodingFailed(error)
        }
    }

    /// Read data from a file URL, decode, and validate the `WorkspaceExportPayload`.
    public func decodePayload(from fileURL: URL) throws -> WorkspaceExportPayload {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw JSONImporterError.fileNotFound(fileURL)
        }

        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            throw JSONImporterError.unreadableData(error)
        }

        return try decodePayload(from: data)
    }
}
