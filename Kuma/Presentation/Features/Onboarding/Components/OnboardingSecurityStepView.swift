//
//  OnboardingSecurityStepView.swift
//  Kuma
//
//  Created for Kuma V4 Native macOS App.
//  Zero-compromise Swift 6 Strict Concurrency architecture.
//

import SwiftUI

/// Step 3: Vault Security & Bookmarks Explanation.
public struct OnboardingSecurityStepView: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: KumaSpacing.md) {
            VStack(alignment: .leading, spacing: KumaSpacing.xs) {
                Text("Vault Security & Bookmarks 🔒")
                    .font(KumaTheme.Font.title1)
                    .foregroundStyle(KumaTheme.Color.textPrimary)

                Text("Kuma protects your sensitive credentials with native macOS security standards.")
                    .font(KumaTheme.Font.body)
                    .foregroundStyle(KumaTheme.Color.textSecondary)
            }

            VStack(spacing: KumaSpacing.sm) {
                securityCard(
                    icon: "lock.shield.fill",
                    color: KumaTheme.Color.accent,
                    title: "Master Key Vault Encryption",
                    description: "SSH passwords, auth tokens, and private keys are encrypted locally using AES-256-GCM. Plain text credentials are never saved to disk."
                )

                securityCard(
                    icon: "bookmark.fill",
                    color: KumaTheme.Color.providerSSH,
                    title: "Sandbox Security Bookmarks",
                    description: "Access to file paths like ~/.kube/config is stored as security-scoped bookmark BLOBs so permissions persist across application restarts."
                )
            }
        }
    }

    private func securityCard(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: KumaSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(KumaTheme.Font.headline)
                    .foregroundStyle(KumaTheme.Color.textPrimary)

                Text(description)
                    .font(KumaTheme.Font.body)
                    .foregroundStyle(KumaTheme.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(KumaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KumaTheme.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: KumaRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: KumaRadius.md)
                .stroke(KumaTheme.Color.cardBorder, lineWidth: 1)
        )
    }
}

#Preview("Security Step") {
    OnboardingSecurityStepView()
        .padding()
        .frame(width: 600)
}
