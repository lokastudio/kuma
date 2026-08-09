//
//  Workspace.swift
//  Kuma
//
//  Created for Task 2.3 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Pure domain model representing a Workspace environment in Kuma.
public struct Workspace: Identifiable, Codable, Sendable, Equatable, Hashable {
    public let id: UUID
    public var name: String
    public var imagePath: String?
    public var sortOrder: Int
    public let createdAt: Date
    public var updatedAt: Date

    public nonisolated init(
        id: UUID = UUID(),
        name: String,
        imagePath: String? = nil,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
