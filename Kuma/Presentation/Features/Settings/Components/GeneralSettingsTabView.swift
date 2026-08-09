//
//  GeneralSettingsTabView.swift
//  Kuma
//
//  Created for Task 7.8 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Tab view displaying General Application Settings and Confirm Quit Safety options.
public struct GeneralSettingsTabView: View {
    @AppStorage("confirmQuitEnabled") private var confirmQuitEnabled: Bool = true
    @AppStorage("playSoundEffects") private var playSoundEffects: Bool = true

    public init() {}

    public var body: some View {
        VStack(spacing: KumaSpacing.lg) {
            KumaFormSection(title: "Application Behavior") {
                KumaToggleField(
                    title: "Confirm Quit Safety",
                    isOn: $confirmQuitEnabled,
                    description: "Prompts a confirmation dialog before quitting when active services are running to prevent unexpected container drops."
                )

                Divider()

                KumaToggleField(
                    title: "Audio Feedback",
                    isOn: $playSoundEffects,
                    description: "Plays subtle native sound effects on service state changes, port conflict resolution, and toast alerts."
                )
            }

            KumaFormSection(title: "System Information") {
                HStack {
                    VStack(alignment: .leading, spacing: KumaSpacing.xs) {
                        Text("Kuma Version")
                            .font(KumaTheme.Font.body)
                            .foregroundStyle(KumaTheme.Color.textPrimary)
                        Text("v4.0.0 (Swift 6 Strict Concurrency Architecture)")
                            .font(KumaTheme.Font.caption)
                            .foregroundStyle(KumaTheme.Color.textSecondary)
                    }
                    Spacer()
                }
            }

            Spacer()
        }
    }
}

#Preview("GeneralSettingsTabView") {
    GeneralSettingsTabView()
        .padding()
        .frame(width: 500, height: 400)
        .background(KumaTheme.Color.windowBackground)
}
