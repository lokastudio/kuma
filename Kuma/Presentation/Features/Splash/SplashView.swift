//
//  SplashView.swift
//  Kuma
//
//  Created for Kuma V4 Native macOS App.
//  Zero-compromise Swift 6 Strict Concurrency architecture.
//

import SwiftUI

/// `SplashView` presented during initial application startup (`.splash` phase).
/// Features subtle micro-animations, fast-track workspace detection, zero heavy allocation, and auto-transition.
public struct SplashView: View {
    @Environment(AppStore.self) private var appStore
    @Environment(WorkspaceStore.self) private var workspaceStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var logoScale: CGFloat = 0.88
    @State private var logoOpacity: Double = 0.0
    @State private var isPulsing: Bool = false

    public init() {}

    public var body: some View {
        VStack(spacing: KumaSpacing.lg) {
            Spacer()

            // MARK: - Animated App Icon / Logo Emblem
            ZStack {
                Circle()
                    .fill(KumaTheme.Color.accent.opacity(0.12))
                    .frame(width: 104, height: 104)
                    .scaleEffect(reduceMotion ? 1.0 : (isPulsing ? 1.08 : 0.95))
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                        value: isPulsing
                    )

                Image(systemName: "square.stack.3d.up.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                KumaTheme.Color.accent,
                                KumaTheme.Color.providerKubernetes
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(logoScale)
            .opacity(logoOpacity)

            // MARK: - Brand Title & Loading Indicator
            VStack(spacing: KumaSpacing.xs) {
                Text("Kuma")
                    .font(KumaTheme.Font.title1)
                    .foregroundStyle(KumaTheme.Color.textPrimary)

                HStack(spacing: KumaSpacing.xs) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Initializing Kuma Engine...")
                        .font(KumaTheme.Font.caption)
                        .foregroundStyle(KumaTheme.Color.textSecondary)
                }
            }
            .opacity(logoOpacity)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.thinMaterial)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Kuma Engine Initializing")
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            if !reduceMotion {
                isPulsing = true
            }

            // Fast-track bootstrap task
            Task { @MainActor in
                await performBootstrapCheck()
            }
        }
    }

    // MARK: - Bootstrap Check & Transition Logic

    private func performBootstrapCheck() async {
        // Guarantee minimal display time (400ms) for visual smoothness
        do {
            try await Task.sleep(nanoseconds: 400_000_000)
        } catch {
            return // Task cancelled, exit gracefully without state mutation
        }

        guard !Task.isCancelled else { return }

        // Load active workspace state
        await workspaceStore.loadWorkspaces()

        guard !Task.isCancelled else { return }

        if workspaceStore.workspaces.isEmpty {
            appStore.transitionToPhase(.onboarding(step: 1))
        } else {
            appStore.transitionToPhase(.mainDeck)
        }
    }
}

#Preview("Splash View") {
    SplashView()
        .environment(AppStore(initialPhase: .splash))
        .environment(WorkspaceStore.mock)
        .frame(width: 500, height: 340)
}
