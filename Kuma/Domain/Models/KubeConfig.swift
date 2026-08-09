//
//  KubeConfig.swift
//  Kuma
//
//  Created for Task 2.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Pure domain model representing a registered KubeConfig reference and its security-scoped bookmark data.
public struct KubeConfig: Identifiable, Codable, Sendable, Equatable, Hashable {
    public let id: UUID
    public var name: String
    public var path: String
    public var bookmarkData: Data?
    public var configContentEncrypted: Data?
    public var isDefault: Bool
    public let createdAt: Date
    public var updatedAt: Date

    public nonisolated init(
        id: UUID = UUID(),
        name: String,
        path: String,
        bookmarkData: Data? = nil,
        configContentEncrypted: Data? = nil,
        isDefault: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.bookmarkData = bookmarkData
        self.configContentEncrypted = configContentEncrypted
        self.isDefault = isDefault
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
