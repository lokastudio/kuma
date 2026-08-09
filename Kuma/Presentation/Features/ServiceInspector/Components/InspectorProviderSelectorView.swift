//
//  InspectorProviderSelectorView.swift
//  Kuma
//
//  Created for Task 7.7 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Selector view allowing seamless switching of the active execution provider without losing context.
@MainActor
public struct InspectorProviderSelectorView: View {
    public let providers: [Provider]
    public let activeProvider: Provider?
    public let onSelectProvider: (Provider) -> Void

    public init(
        providers: [Provider],
        activeProvider: Provider?,
        onSelectProvider: @escaping (Provider) -> Void
    ) {
        self.providers = providers
        self.activeProvider = activeProvider
        self.onSelectProvider = onSelectProvider
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: KumaSpacing.xs) {
            KumaSectionHeader(title: "ACTIVE PROVIDER", subtitle: "Switch runtime engine")

            if providers.isEmpty {
                Text("No providers configured (e.g. forwarder-mongo-stage)")
                    .font(KumaTheme.Font.caption)
                    .foregroundStyle(KumaTheme.Color.textSecondary)
                    .padding(KumaSpacing.sm)
            } else {
                HStack(spacing: KumaSpacing.xs) {
                    ForEach(providers) { provider in
                        let isSelected = provider.id == activeProvider?.id
                        Button {
                            onSelectProvider(provider)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: provider.providerType.systemImage)
                                    .font(.system(size: 11, weight: .semibold))
                                Text(provider.providerType.displayName)
                                    .font(KumaTheme.Font.caption)
                                    .fontWeight(isSelected ? .bold : .medium)
                            }
                            .foregroundStyle(isSelected ? Color.white : KumaTheme.Color.textPrimary)
                            .padding(.horizontal, KumaSpacing.sm)
                            .padding(.vertical, 6)
                            .background(
                                isSelected ? KumaTheme.Color.accent : KumaTheme.Color.surfaceBackground,
                                in: RoundedRectangle(cornerRadius: KumaRadius.sm, style: .continuous)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Select provider \(provider.providerType.displayName)")
                    }
                }
            }
        }
        .padding(.horizontal, KumaSpacing.md)
    }
}
