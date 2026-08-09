//
//  KubeConfigSettingsTabView.swift
//  Kuma
//
//  Created for Task 7.8 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Tab view displaying KubeConfig Context Sync status and manual refresh triggers.
public struct KubeConfigSettingsTabView: View {
    @Environment(KubeConfigStore.self) private var kubeConfigStore

    public init() {}

    public var body: some View {
        VStack(spacing: KumaSpacing.lg) {
            KumaFormSection(title: "KubeConfig Discovery & Security Bookmarks") {
                HStack {
                    VStack(alignment: .leading, spacing: KumaSpacing.xs) {
                        Text("Active KubeConfig Path")
                            .font(KumaTheme.Font.body)
                            .foregroundStyle(KumaTheme.Color.textPrimary)
                        Text(kubeConfigStore.selectedKubeConfig?.path ?? "~/.kube/config")
                            .font(KumaTheme.Font.code)
                            .foregroundStyle(KumaTheme.Color.textSecondary)
                    }
                    Spacer()

                    Button("Reload Contexts") {
                        Task {
                            await kubeConfigStore.loadKubeConfigs()
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Reload KubeConfig Contexts")
                }

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: KumaSpacing.xs) {
                        Text("Discovered Configurations")
                            .font(KumaTheme.Font.body)
                            .foregroundStyle(KumaTheme.Color.textPrimary)
                        Text("\(kubeConfigStore.kubeConfigs.count) KubeConfig reference(s) available")
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

#Preview("KubeConfigSettingsTabView") {
    KubeConfigSettingsTabView()
        .environment(KubeConfigStore.mock)
        .padding()
        .frame(width: 500, height: 400)
        .background(KumaTheme.Color.windowBackground)
}
