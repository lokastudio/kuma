//
//  OnboardingReadyStepView.swift
//  Kuma
//
//  Created for Kuma V4 Native macOS App.
//  Zero-compromise Swift 6 Strict Concurrency architecture.
//

import SwiftUI

/// Step 4: Summary & Launch Preparedness.
public struct OnboardingReadyStepView: View {
    public let workspaceName: String
    public let detectedToolsCount: Int
    public let totalToolsCount: Int

    public init(workspaceName: String, detectedToolsCount: Int, totalToolsCount: Int) {
        self.workspaceName = workspaceName
        self.detectedToolsCount = detectedToolsCount
        self.totalToolsCount = totalToolsCount
    }

    public var body: some View {
        VStack(spacing: KumaSpacing.md) {
            ZStack {
                Circle()
                    .fill(KumaTheme.Color.statusRunning.opacity(0.12))
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(KumaTheme.Color.statusRunning)
            }

            VStack(spacing: KumaSpacing.xs) {
                Text("You're All Set! 🎉")
                    .font(KumaTheme.Font.title1)
                    .foregroundStyle(KumaTheme.Color.textPrimary)

                Text("Kuma is ready to manage your services and port forwards.")
                    .font(KumaTheme.Font.body)
                    .foregroundStyle(KumaTheme.Color.textSecondary)
            }

            VStack(spacing: KumaSpacing.xs) {
                HStack {
                    Text("Initial Workspace:")
                        .font(KumaTheme.Font.subheadline)
                        .foregroundStyle(KumaTheme.Color.textSecondary)
                    Spacer()
                    Text(workspaceName.isEmpty ? "Default Workspace" : workspaceName)
                        .font(KumaTheme.Font.headline)
                        .foregroundStyle(KumaTheme.Color.textPrimary)
                }

                Divider()

                HStack {
                    Text("Detected CLI Tools:")
                        .font(KumaTheme.Font.subheadline)
                        .foregroundStyle(KumaTheme.Color.textSecondary)
                    Spacer()
                    Text("\(detectedToolsCount) of \(totalToolsCount) Available")
                        .font(KumaTheme.Font.headline)
                        .foregroundStyle(KumaTheme.Color.statusRunning)
                }
            }
            .padding(KumaSpacing.md)
            .background(KumaTheme.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: KumaRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: KumaRadius.md)
                    .stroke(KumaTheme.Color.cardBorder, lineWidth: 1)
            )
        }
    }
}

#Preview("Ready Step") {
    OnboardingReadyStepView(
        workspaceName: "Personal Stack",
        detectedToolsCount: 4,
        totalToolsCount: 5
    )
    .padding()
    .frame(width: 600)
}
