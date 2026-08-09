//
//  OnboardingEnginesStepView.swift
//  Kuma
//
//  Created for Kuma V4 Native macOS App.
//  Zero-compromise Swift 6 Strict Concurrency architecture.
//

import SwiftUI

/// Step 2: CLI Discovery & Path Resolution.
public struct OnboardingEnginesStepView: View {
    @Binding public var toolStates: [ToolDetectionState]
    public let isScanning: Bool
    public let onRescan: () -> Void

    public init(
        toolStates: Binding<[ToolDetectionState]>,
        isScanning: Bool,
        onRescan: @escaping () -> Void
    ) {
        self._toolStates = toolStates
        self.isScanning = isScanning
        self.onRescan = onRescan
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: KumaSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: KumaSpacing.xs) {
                    Text("Engine & CLI Discovery ⚙️")
                        .font(KumaTheme.Font.title1)
                        .foregroundStyle(KumaTheme.Color.textPrimary)

                    Text("Kuma automatically sniffs your system `$PATH` for installed local tools.")
                        .font(KumaTheme.Font.body)
                        .foregroundStyle(KumaTheme.Color.textSecondary)
                }

                Spacer()

                Button(action: onRescan) {
                    HStack(spacing: KumaSpacing.xs) {
                        if isScanning {
                            ProgressView().controlSize(.small)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text("Rescan")
                    }
                }
                .disabled(isScanning)
                .accessibilityLabel("Rescan system CLI tools")
            }

            VStack(spacing: KumaSpacing.xs) {
                ForEach(toolStates) { tool in
                    HStack(spacing: KumaSpacing.sm) {
                        Circle()
                            .fill(KumaColor.forProviderKey(tool.providerKey))
                            .frame(width: 10, height: 10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(tool.name)
                                .font(KumaTheme.Font.headline)
                                .foregroundStyle(KumaTheme.Color.textPrimary)

                            if let path = tool.resolvedPath {
                                Text(path)
                                    .font(KumaTheme.Font.caption)
                                    .foregroundStyle(KumaTheme.Color.textMuted)
                            } else {
                                Text("Not found in $PATH. Install via Homebrew or specify path in Settings.")
                                    .font(KumaTheme.Font.caption)
                                    .foregroundStyle(KumaTheme.Color.textSecondary)
                            }
                        }

                        Spacer()

                        if tool.isDetected {
                            Label("Installed", systemImage: "checkmark.circle.fill")
                                .font(KumaTheme.Font.caption)
                                .foregroundStyle(KumaTheme.Color.statusRunning)
                        } else {
                            Label("Missing", systemImage: "exclamationmark.triangle.fill")
                                .font(KumaTheme.Font.caption)
                                .foregroundStyle(KumaTheme.Color.statusStarting)
                        }
                    }
                    .padding(KumaSpacing.sm)
                    .background(KumaTheme.Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: KumaRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: KumaRadius.md)
                            .stroke(KumaTheme.Color.cardBorder, lineWidth: 1)
                    )
                }
            }
        }
    }
}

#Preview("Engines Step") {
    OnboardingEnginesStepView(
        toolStates: .constant([
            ToolDetectionState(name: "kubectl", providerKey: "k8s", isDetected: true, resolvedPath: "/opt/homebrew/bin/kubectl"),
            ToolDetectionState(name: "docker", providerKey: "docker", isDetected: false, resolvedPath: nil)
        ]),
        isScanning: false,
        onRescan: {}
    )
    .padding()
    .frame(width: 600)
}
