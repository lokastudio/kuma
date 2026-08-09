//
//  AppStore.swift
//  Kuma
//

import Foundation
import Observation
import os

/// `@Observable` root container managing application lifecycle, global navigation, toast alerts, and inspector drawer state.
@MainActor
@Observable
public final class AppStore {
    private static let logger = Logger(subsystem: "lokastudio.kuma", category: "AppStore")

    // MARK: - State Properties

    /// Active application phase (splash -> onboarding -> mainDeck).
    public private(set) var appPhase: AppPhase

    /// Currently active toast notification.
    public private(set) var activeToast: KumaToastNotification?

    /// Currently selected service ID for Inspector panel.
    public var selectedServiceId: UUID?

    /// Visibility of the right Inspector drawer panel.
    public var isInspectorPresented: Bool

    // MARK: - Initialization

    public init(initialPhase: AppPhase = .splash) {
        self.appPhase = initialPhase
        self.activeToast = nil
        self.selectedServiceId = nil
        self.isInspectorPresented = false
        Self.logger.debug("AppStore initialized with phase: \(String(describing: initialPhase))")
    }

    // MARK: - Phase Navigation

    /// Transition to a new application phase.
    public func transitionToPhase(_ newPhase: AppPhase) {
        Self.logger.info("Transitioning AppPhase to: \(String(describing: newPhase))")
        self.appPhase = newPhase
    }

    /// Task tracking auto-dismissal of active toast.
    private var toastDismissTask: Task<Void, Never>?

    // MARK: - Toast Notification Management

    /// Displays a toast notification with automated dismissal after `durationSeconds`.
    public func showToast(_ toast: KumaToastNotification) {
        Self.logger.debug("Showing toast: \(toast.title, privacy: .public)")
        self.toastDismissTask?.cancel()
        self.activeToast = toast

        let durationNanoseconds = UInt64(toast.durationSeconds * 1_000_000_000)
        self.toastDismissTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(nanoseconds: durationNanoseconds)
                if self?.activeToast?.id == toast.id {
                    self?.activeToast = nil
                }
            } catch {
                // Task cancelled due to manual dismissal or new toast
            }
        }
    }

    /// Dismisses the currently visible toast notification immediately.
    public func dismissToast() {
        self.toastDismissTask?.cancel()
        self.toastDismissTask = nil
        self.activeToast = nil
    }

    // MARK: - Inspector Panel Management

    /// Toggles or opens the inspector drawer for a specific service.
    public func selectServiceForInspector(_ serviceId: UUID?) {
        if let id = serviceId {
            self.selectedServiceId = id
            self.isInspectorPresented = true
        } else {
            self.selectedServiceId = nil
            self.isInspectorPresented = false
        }
    }

    /// Toggles the inspector open/closed state.
    public func toggleInspector() {
        self.isInspectorPresented.toggle()
        if !self.isInspectorPresented {
            self.selectedServiceId = nil
        }
    }

    // MARK: - Mock for Previews & Unit Tests

    /// Mock `AppStore` pre-loaded for SwiftUI `#Preview` and tests.
    public static var mock: AppStore {
        let store = AppStore(initialPhase: .mainDeck)
        store.showToast(KumaToastNotification(title: "Mock Ready", style: .success))
        return store
    }
}
