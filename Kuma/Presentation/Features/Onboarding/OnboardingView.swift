//
//  OnboardingView.swift
//  Kuma
//
//  Created for Kuma V4 Native macOS App.
//  Zero-compromise Swift 6 Strict Concurrency architecture.
//

import SwiftUI

/// 4-Step Onboarding Wizard View (`.onboarding` phase).
/// Handles initial workspace configuration, CLI discovery, vault overview, and transition to `.mainDeck`.
public struct OnboardingView: View {
    @Environment(AppStore.self) private var appStore
    @Environment(WorkspaceStore.self) private var workspaceStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var currentStep: Int = 1
    @State private var workspaceName: String = "Personal Stack"
    @State private var isScanning: Bool = false
    @State private var toolStates: [ToolDetectionState] = [
        ToolDetectionState(name: "kubectl", providerKey: "k8s", isDetected: false, resolvedPath: nil),
        ToolDetectionState(name: "docker", providerKey: "docker", isDetected: false, resolvedPath: nil),
        ToolDetectionState(name: "podman", providerKey: "podman", isDetected: false, resolvedPath: nil),
        ToolDetectionState(name: "ssh", providerKey: "ssh", isDetected: false, resolvedPath: nil),
        ToolDetectionState(name: "cloudflared", providerKey: "tunnel", isDetected: false, resolvedPath: nil)
    ]

    public init(initialStep: Int = 1) {
        _currentStep = State(initialValue: initialStep)
    }

    public var body: some View {
        VStack(spacing: KumaSpacing.lg) {
            OnboardingProgressHeader(currentStep: currentStep, totalSteps: 4)

            Spacer(minLength: 0)

            Group {
                switch currentStep {
                case 1:
                    OnboardingWelcomeStepView(workspaceName: $workspaceName)
                case 2:
                    OnboardingEnginesStepView(
                        toolStates: $toolStates,
                        isScanning: isScanning,
                        onRescan: {
                            Task { @MainActor in
                                await scanSystemTools()
                            }
                        }
                    )
                case 3:
                    OnboardingSecurityStepView()
                case 4:
                    OnboardingReadyStepView(
                        workspaceName: workspaceName,
                        detectedToolsCount: toolStates.filter(\.isDetected).count,
                        totalToolsCount: toolStates.count
                    )
                default:
                    EmptyView()
                }
            }
            .transition(reduceMotion ? .identity : .opacity)

            Spacer(minLength: 0)

            // Navigation bar controls
            HStack {
                if currentStep > 1 {
                    Button("Back") {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                            currentStep -= 1
                        }
                    }
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    .accessibilityLabel("Previous onboarding step")
                }

                Spacer()

                if currentStep < 4 {
                    Button(action: advanceStep) {
                        Text("Next")
                            .font(KumaTheme.Font.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(KumaTheme.Color.accent)
                    .disabled(currentStep == 1 && workspaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .keyboardShortcut(.defaultAction)
                    .accessibilityLabel("Next onboarding step")
                } else {
                    Button(action: finishOnboarding) {
                        Text("Get Started with Kuma")
                            .font(KumaTheme.Font.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(KumaTheme.Color.accent)
                    .keyboardShortcut(.defaultAction)
                    .accessibilityLabel("Finish onboarding and open main deck")
                }
            }
        }
        .padding(KumaSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.thinMaterial)
        .onAppear {
            Task { @MainActor in
                await scanSystemTools()
            }
        }
    }

    // MARK: - Private Action Helpers

    private func advanceStep() {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            currentStep += 1
        }
    }

    private func scanSystemTools() async {
        isScanning = true
        let resolver = EnvironmentPathResolver.shared

        var updated: [ToolDetectionState] = []
        for var tool in toolStates {
            let path = await resolver.resolveExecutablePath(for: tool.name)
            tool.isDetected = (path != nil)
            tool.resolvedPath = path
            updated.append(tool)
        }

        self.toolStates = updated
        self.isScanning = false
    }

    private func finishOnboarding() {
        Task { @MainActor in
            let name = workspaceName.trimmingCharacters(in: .whitespacesAndNewlines)
            let finalName = name.isEmpty ? "Default Workspace" : name
            await workspaceStore.createWorkspace(name: finalName)
            appStore.transitionToPhase(.mainDeck)
        }
    }
}

#Preview("Onboarding View") {
    OnboardingView()
        .environment(AppStore(initialPhase: .onboarding(step: 1)))
        .environment(WorkspaceStore.mock)
        .frame(width: 720, height: 480)
}
