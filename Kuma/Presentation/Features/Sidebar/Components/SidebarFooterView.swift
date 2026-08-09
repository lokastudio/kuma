//
//  SidebarFooterView.swift
//  Kuma
//
//  Created for Task 7.4 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Fixed system footer containing `❓ Help & Guide` and `⚙️ Settings`.
public struct SidebarFooterView: View {
    @Binding public var selection: SidebarSelection?

    public init(selection: Binding<SidebarSelection?>) {
        self._selection = selection
    }

    public var body: some View {
        VStack(spacing: KumaSpacing.xs) {
            Divider()
                .background(KumaTheme.Color.divider)

            HStack(spacing: KumaSpacing.xs) {
                Button {
                    selection = .help
                } label: {
                    Label("Help & Guide", systemImage: "questionmark.circle")
                        .font(KumaTheme.Font.caption)
                        .foregroundStyle(KumaTheme.Color.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Help and Guide")

                Spacer()

                Button {
                    selection = .settings
                } label: {
                    Label("Settings", systemImage: "gearshape")
                        .font(KumaTheme.Font.caption)
                        .foregroundStyle(KumaTheme.Color.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("App Settings")
            }
            .padding(.horizontal, KumaSpacing.sm)
            .padding(.bottom, KumaSpacing.xs)
        }
    }
}

#Preview("SidebarFooterView") {
    SidebarFooterView(selection: .constant(.settings))
        .frame(width: 240)
}
