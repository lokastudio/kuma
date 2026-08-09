//
//  KumaToastNotification.swift
//  Kuma
//

import Foundation

/// Represents a global transient toast notification in Kuma V4.
public struct KumaToastNotification: Identifiable, Equatable, Sendable {
    public enum Style: Sendable {
        case info
        case success
        case warning
        case error
    }

    public let id: UUID
    public let title: String
    public let message: String?
    public let style: Style
    public let durationSeconds: Double

    public init(
        id: UUID = UUID(),
        title: String,
        message: String? = nil,
        style: Style = .info,
        durationSeconds: Double = 3.0
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.style = style
        self.durationSeconds = durationSeconds
    }
}
