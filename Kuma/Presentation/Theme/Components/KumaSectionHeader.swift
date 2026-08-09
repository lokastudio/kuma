//
//  KumaSectionHeader.swift
//  Kuma
//

import SwiftUI

/// Header component supporting primary title, secondary subtitle, and an optional right-aligned action view.
@MainActor
public struct KumaSectionHeader<ActionContent: View>: View {
    private let title: String
    private let subtitle: String?
    private let actionContent: ActionContent?

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder actionContent: () -> ActionContent
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionContent = actionContent()
    }

    public init(
        title: String,
        subtitle: String? = nil
    ) where ActionContent == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.actionContent = nil
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: KumaSpacing.sm) {
            VStack(alignment: .leading, spacing: KumaSpacing.xs) {
                Text(title)
                    .font(KumaFont.headline)
                    .foregroundColor(KumaColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(KumaFont.subheadline)
                        .foregroundColor(KumaColor.textSecondary)
                }
            }

            Spacer()

            if let actionContent {
                actionContent
            }
        }
    }
}

#Preview {
    VStack(spacing: KumaSpacing.lg) {
        KumaSectionHeader(
            title: "General Settings",
            subtitle: "Manage basic app preferences and execution behavior."
        ) {
            Button("Reset") {}
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }

        KumaSectionHeader(
            title: "Network Configuration",
            subtitle: "Port forwarding settings"
        )
    }
    .padding()
    .frame(width: 400)
    .background(KumaColor.surfaceBackground)
}
