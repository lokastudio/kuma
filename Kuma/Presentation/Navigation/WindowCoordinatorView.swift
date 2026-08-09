//
//  WindowCoordinatorView.swift
//  Kuma
//
//  Created for Kuma V4 Native macOS App.
//  Zero-compromise Swift 6 Strict Concurrency architecture.
//

import SwiftUI

/// Container view that observes `AppStore.appPhase` and renders the appropriate phase view with dynamic frame sizing.
public struct WindowCoordinatorView: View {
    @Environment(AppStore.self) private var appStore
    @State private var coordinator = WindowCoordinator()

    public init() {}

    public var body: some View {
        Group {
            switch appStore.appPhase {
            case .splash:
                SplashPlaceholderView()
            case .onboarding:
                OnboardingPlaceholderView()
            case .mainDeck:
                MainDeckPlaceholderView()
            }
        }
        .frame(
            minWidth: coordinator.currentDimensions.minWidth,
            idealWidth: coordinator.currentDimensions.idealWidth,
            maxWidth: coordinator.currentDimensions.maxWidth,
            minHeight: coordinator.currentDimensions.minHeight,
            idealHeight: coordinator.currentDimensions.idealHeight,
            maxHeight: coordinator.currentDimensions.maxHeight
        )
        .animation(.easeInOut(duration: 0.25), value: appStore.appPhase)
        .onAppear {
            coordinator.updateDimensions(for: appStore.appPhase)
        }
        .onChange(of: appStore.appPhase) { _, newPhase in
            coordinator.updateDimensions(for: newPhase)
        }
    }
}

// MARK: - Temporary Phase Placeholders (Replaced in Tasks 7.2 - 7.5)

private struct SplashPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
            Text("Initializing Kuma Engine...")
                .font(KumaTheme.Font.subheadline)
                .foregroundStyle(KumaTheme.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct OnboardingPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to Kuma")
                .font(KumaTheme.Font.title1)
                .foregroundStyle(KumaTheme.Color.textPrimary)
            Text("Onboarding Wizard Scaffold")
                .font(KumaTheme.Font.body)
                .foregroundStyle(KumaTheme.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MainDeckPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Kuma Main Deck")
                .font(KumaTheme.Font.title1)
                .foregroundStyle(KumaTheme.Color.textPrimary)
            Text("Service & Kubernetes Deck Scaffold")
                .font(KumaTheme.Font.body)
                .foregroundStyle(KumaTheme.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Splash Phase") {
    WindowCoordinatorView()
        .environment(AppStore(initialPhase: .splash))
}

#Preview("Main Deck Phase") {
    WindowCoordinatorView()
        .environment(AppStore.mock)
}
