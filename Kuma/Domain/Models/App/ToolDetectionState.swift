//
//  ToolDetectionState.swift
//  Kuma
//
//  Created for Kuma V4 Native macOS App.
//  Zero-compromise Swift 6 Strict Concurrency architecture.
//

import Foundation

/// CLI Tool detection status model for onboarding & system diagnostics.
public struct ToolDetectionState: Identifiable, Sendable {
    public var id: String { name }
    public let name: String
    public let providerKey: String
    public var isDetected: Bool
    public var resolvedPath: String?

    public init(name: String, providerKey: String, isDetected: Bool, resolvedPath: String? = nil) {
        self.name = name
        self.providerKey = providerKey
        self.isDetected = isDetected
        self.resolvedPath = resolvedPath
    }
}
