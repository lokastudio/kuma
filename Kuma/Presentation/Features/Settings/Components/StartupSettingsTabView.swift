//
//  StartupSettingsTabView.swift
//  Kuma
//
//  Created for Task 7.8 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Tab view displaying Launch at Login (`SMAppService`) and Auto-Start Service Restoration settings.
public struct StartupSettingsTabView: View {
    @AppStorage("autoStartServicesEnabled") private var autoStartServicesEnabled: Bool = true
    @State private var launchAtLoginEnabled: Bool = LaunchAtLoginManager.shared.isEnabled
    @State private var errorMessage: String?

    public init() {}

    public var body: some View {
        VStack(spacing: KumaSpacing.lg) {
            KumaFormSection(title: "Startup & Login Items") {
                Toggle(isOn: Binding(
                    get: { launchAtLoginEnabled },
                    set: { newValue in
                        do {
                            try LaunchAtLoginManager.shared.setEnabled(newValue)
                            launchAtLoginEnabled = newValue
                            errorMessage = nil
                        } catch {
                            errorMessage = "Failed to update Launch at Login: \(error.localizedDescription)"
                        }
                    }
                )) {
                    VStack(alignment: .leading, spacing: KumaSpacing.xs) {
                        Text("Launch Kuma at Login")
                            .font(KumaTheme.Font.body)
                            .foregroundStyle(KumaTheme.Color.textPrimary)
                        Text("Automatically launches Kuma in background menu bar when starting your Mac (uses native SMAppService).")
                            .font(KumaTheme.Font.caption)
                            .foregroundStyle(KumaTheme.Color.textSecondary)
                    }
                }
                .toggleStyle(.switch)

                if let errorMessage {
                    Text(errorMessage)
                        .font(KumaTheme.Font.caption)
                        .foregroundStyle(KumaTheme.Color.statusFailed)
                        .padding(.top, KumaSpacing.xs)
                }

                Divider()

                KumaToggleField(
                    title: "Auto-Start Active Services",
                    isOn: $autoStartServicesEnabled,
                    description: "Restores running services from previous session on Kuma application launch."
                )
            }

            Spacer()
        }
        .onAppear {
            launchAtLoginEnabled = LaunchAtLoginManager.shared.isEnabled
        }
    }
}

#Preview("StartupSettingsTabView") {
    StartupSettingsTabView()
        .padding()
        .frame(width: 500, height: 400)
        .background(KumaTheme.Color.windowBackground)
}
