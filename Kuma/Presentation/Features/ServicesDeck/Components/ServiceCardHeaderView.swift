//
//  ServiceCardHeaderView.swift
//  Kuma
//
//  Created for Task 7.6 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Header layout displaying service name, active provider type badge, and service execution status pill.
@MainActor
public struct ServiceCardHeaderView: View {
    public let title: String
    public let providerType: ProviderType?
    public let state: ServiceExecutionState

    public init(
        title: String,
        providerType: ProviderType?,
        state: ServiceExecutionState
    ) {
        self.title = title
        self.providerType = providerType
        self.state = state
    }

    public var body: some View {
        HStack(spacing: KumaSpacing.sm) {
            Text(title)
                .font(KumaTheme.Font.headline)
                .foregroundStyle(KumaTheme.Color.textPrimary)
                .lineLimit(1)

            if let provider = providerType {
                providerBadge(provider)
            }

            Spacer()

            statusPill(state)
        }
    }

    private func providerBadge(_ provider: ProviderType) -> some View {
        HStack(spacing: 4) {
            Image(systemName: provider.iconName)
                .font(.system(size: 10, weight: .semibold))
            Text(provider.displayName)
                .font(KumaTheme.Font.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(KumaTheme.Color.textSecondary)
        .padding(.horizontal, KumaSpacing.xs)
        .padding(.vertical, 2)
        .background(
            KumaTheme.Color.surfaceBackground,
            in: RoundedRectangle(cornerRadius: KumaRadius.sm, style: .continuous)
        )
    }

    private func statusPill(_ state: ServiceExecutionState) -> some View {
        HStack(spacing: KumaSpacing.xs) {
            Circle()
                .fill(stateColor(for: state))
                .frame(width: 6, height: 6)

            Text(stateTitle(for: state))
                .font(KumaTheme.Font.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(stateForegroundColor(for: state))
        .padding(.horizontal, KumaSpacing.sm)
        .padding(.vertical, 4)
        .background(
            stateBackgroundColor(for: state),
            in: Capsule()
        )
    }

    private func stateColor(for state: ServiceExecutionState) -> Color {
        KumaTheme.Color.forState(state)
    }

    private func stateTitle(for state: ServiceExecutionState) -> String {
        switch state {
        case .stopped: return "Stopped"
        case .starting: return "Starting"
        case .running: return "Running"
        case .stopping: return "Stopping"
        case .failed: return "Failed"
        }
    }

    private func stateForegroundColor(for state: ServiceExecutionState) -> Color {
        switch state {
        case .running: return Color.white
        case .failed: return Color.white
        default: return KumaTheme.Color.textPrimary
        }
    }

    private func stateBackgroundColor(for state: ServiceExecutionState) -> Color {
        switch state {
        case .running: return KumaTheme.Color.statusRunning
        case .failed: return KumaTheme.Color.statusStopped
        default: return KumaTheme.Color.surfaceBackground
        }
    }
}

private extension ProviderType {
    var iconName: String {
        self.systemImage
    }
}
