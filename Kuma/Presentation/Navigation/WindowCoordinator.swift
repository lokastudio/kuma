//
//  WindowCoordinator.swift
//  Kuma
//
//  Created for Kuma V4 Native macOS App.
//  Zero-compromise Swift 6 Strict Concurrency architecture.
//

import AppKit
import Foundation
import Observation
import os

/// `@MainActor` coordinator for managing single OS window frame bounds, dynamic resizing per `AppPhase`, and single-instance application activation guard.
@MainActor
@Observable
public final class WindowCoordinator {
    private static let logger = Logger(subsystem: "lokastudio.kuma", category: "WindowCoordinator")

    // MARK: - Window Size Dimensions

    public struct WindowDimensions: Equatable, Sendable {
        public let minWidth: CGFloat
        public let minHeight: CGFloat
        public let idealWidth: CGFloat
        public let idealHeight: CGFloat
        public let maxWidth: CGFloat?
        public let maxHeight: CGFloat?

        public static let splash = WindowDimensions(
            minWidth: 500, minHeight: 340,
            idealWidth: 500, idealHeight: 340,
            maxWidth: 500, maxHeight: 340
        )

        public static let onboarding = WindowDimensions(
            minWidth: 680, minHeight: 440,
            idealWidth: 720, idealHeight: 480,
            maxWidth: 900, maxHeight: 600
        )

        public static let mainDeck = WindowDimensions(
            minWidth: 960, minHeight: 600,
            idealWidth: 1100, idealHeight: 720,
            maxWidth: nil, maxHeight: nil
        )
    }

    // MARK: - Properties

    /// Current target window dimensions derived from active phase.
    public private(set) var currentDimensions: WindowDimensions = .splash

    // MARK: - Initialization

    public init() {
        Self.logger.debug("WindowCoordinator initialized")
    }

    // MARK: - Phase Dimensions Resolution

    /// Updates window dimension constraints based on active `AppPhase`.
    public func updateDimensions(for phase: AppPhase) {
        let newDimensions: WindowDimensions
        switch phase {
        case .splash:
            newDimensions = .splash
        case .onboarding:
            newDimensions = .onboarding
        case .mainDeck:
            newDimensions = .mainDeck
        }

        Self.logger.info("Updating window dimensions for phase \(String(describing: phase)): \(newDimensions.idealWidth)x\(newDimensions.idealHeight)")
        self.currentDimensions = newDimensions
    }

    // MARK: - Single Instance Guard (macOS 14+ Modern SDK)

    /// Checks if another instance of Kuma is already running and brings it to front.
    /// Returns `true` if another instance was found and activated.
    @discardableResult
    public static func activateExistingInstanceIfRunning() -> Bool {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return false }
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)

        let currentPID = ProcessInfo.processInfo.processIdentifier
        if let existingApp = runningApps.first(where: { $0.processIdentifier != currentPID }) {
            logger.info("Found existing Kuma instance (PID: \(existingApp.processIdentifier)). Activating running instance.")
            existingApp.activate()
            return true
        }

        return false
    }
}
