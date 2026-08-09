//
//  OnboardingWelcomeStepView.swift
//  Kuma
//
//  Created for Kuma V4 Native macOS App.
//  Zero-compromise Swift 6 Strict Concurrency architecture.
//

import SwiftUI

/// Step 1: Welcome & Initial Workspace Setup.
public struct OnboardingWelcomeStepView: View {
    @Binding public var workspaceName: String

    public init(workspaceName: Binding<String>) {
        self._workspaceName = workspaceName
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: KumaSpacing.md) {
            VStack(alignment: .leading, spacing: KumaSpacing.xs) {
                Text("Welcome to Kuma 🚀")
                    .font(KumaTheme.Font.title1)
                    .foregroundStyle(KumaTheme.Color.textPrimary)

                Text("Manage your local port forwards, Docker stacks, shell runners, and SSH tunnels in a single native macOS workspace.")
                    .font(KumaTheme.Font.body)
                    .foregroundStyle(KumaTheme.Color.textSecondary)
            }

            KumaFormSection(title: "Default Workspace", description: "Name your initial workspace environment to get started.") {
                KumaTextField(
                    title: "Workspace Name",
                    text: $workspaceName,
                    placeholder: "e.g. Personal Stack or Backend Services"
                )
            }
        }
    }
}

#Preview("Welcome Step") {
    OnboardingWelcomeStepView(workspaceName: .constant("Personal Stack"))
        .padding()
        .frame(width: 600)
}
