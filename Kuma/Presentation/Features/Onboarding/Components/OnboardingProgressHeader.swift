//
//  OnboardingProgressHeader.swift
//  Kuma
//
//  Created for Kuma V4 Native macOS App.
//  Zero-compromise Swift 6 Strict Concurrency architecture.
//

import SwiftUI

/// Header progress bar and step indicator for `OnboardingView`.
public struct OnboardingProgressHeader: View {
    public let currentStep: Int
    public let totalSteps: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(currentStep: Int, totalSteps: Int = 4) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
    }

    public var body: some View {
        VStack(spacing: KumaSpacing.xs) {
            HStack {
                Text("Step \(currentStep) of \(totalSteps)")
                    .font(KumaTheme.Font.caption)
                    .foregroundStyle(KumaTheme.Color.textSecondary)

                Spacer()

                Text(stepTitle(for: currentStep))
                    .font(KumaTheme.Font.caption)
                    .foregroundStyle(KumaTheme.Color.textMuted)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(KumaTheme.Color.cardBorder)
                        .frame(height: 6)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [KumaTheme.Color.accent, KumaTheme.Color.providerKubernetes],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geometry.size.width * CGFloat(currentStep) / CGFloat(totalSteps)), height: 6)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .frame(height: 6)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(currentStep) of \(totalSteps): \(stepTitle(for: currentStep))")
    }

    private func stepTitle(for step: Int) -> String {
        switch step {
        case 1: return "Welcome & Workspace"
        case 2: return "CLI Engine Discovery"
        case 3: return "Vault & Security"
        case 4: return "Ready to Launch"
        default: return ""
        }
    }
}

#Preview("Progress Header") {
    OnboardingProgressHeader(currentStep: 2)
        .padding()
        .frame(width: 600)
}
