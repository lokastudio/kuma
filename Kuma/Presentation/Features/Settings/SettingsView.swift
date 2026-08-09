//
//  SettingsView.swift
//  Kuma
//
//  Created for Task 7.8 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Main Settings View presenting application preferences in a multi-tab layout.
public struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general

    public init(initialTab: SettingsTab = .general) {
        _selectedTab = State(initialValue: initialTab)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header / Tab Selector
            HStack(spacing: KumaSpacing.sm) {
                Text("Settings")
                    .font(KumaTheme.Font.title1)
                    .foregroundStyle(KumaTheme.Color.textPrimary)

                Spacer()

                Picker("Tab", selection: $selectedTab) {
                    ForEach(SettingsTab.allCases) { tab in
                        Label(tab.rawValue, systemImage: tab.systemImage)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 320)
            }
            .padding(KumaSpacing.md)

            Divider()
                .background(KumaTheme.Color.divider)

            // Content Area
            Group {
                switch selectedTab {
                case .general:
                    GeneralSettingsTabView()
                case .startup:
                    StartupSettingsTabView()
                case .kubeconfig:
                    KubeConfigSettingsTabView()
                }
            }
            .padding(KumaSpacing.lg)
        }
        .frame(minWidth: 520, idealWidth: 600, minHeight: 400, idealHeight: 480)
        .background(KumaTheme.Color.windowBackground)
    }
}

#Preview("SettingsView General") {
    SettingsView(initialTab: .general)
        .environment(KubeConfigStore.mock)
}

#Preview("SettingsView Startup") {
    SettingsView(initialTab: .startup)
        .environment(KubeConfigStore.mock)
}
