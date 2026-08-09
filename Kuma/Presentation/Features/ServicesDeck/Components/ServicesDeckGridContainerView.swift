//
//  ServicesDeckGridContainerView.swift
//  Kuma
//
//  Created for Task 7.5 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Performance-optimized `LazyVStack` scroll view container displaying service aggregate cards in `ServicesDeckView`.
@MainActor
public struct ServicesDeckGridContainerView: View {
    public let aggregates: [ServiceAggregate]
    @Binding public var selectedServiceId: UUID?
    public let onToggleExecution: (ServiceAggregate) -> Void

    public init(
        aggregates: [ServiceAggregate],
        selectedServiceId: Binding<UUID?>,
        onToggleExecution: @escaping (ServiceAggregate) -> Void
    ) {
        self.aggregates = aggregates
        self._selectedServiceId = selectedServiceId
        self.onToggleExecution = onToggleExecution
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: KumaSpacing.md) {
                ForEach(aggregates) { aggregate in
                    ServicesDeckCardWrapperView(
                        aggregate: aggregate,
                        isSelected: selectedServiceId == aggregate.id,
                        onSelect: { selectedServiceId = aggregate.id },
                        onToggleExecution: { onToggleExecution(aggregate) }
                    )
                }
            }
            .padding(.horizontal, KumaSpacing.md)
            .padding(.vertical, KumaSpacing.sm)
        }
    }
}

/// Structural placeholder wrapper for service card items until Task 7.6 (`ServiceCardView`) implementation.
@MainActor
private struct ServicesDeckCardWrapperView: View {
    let aggregate: ServiceAggregate
    let isSelected: Bool
    let onSelect: () -> Void
    let onToggleExecution: () -> Void

    var body: some View {
        KumaCardContainer(isInteractive: true) {
            HStack(spacing: KumaSpacing.md) {
                VStack(alignment: .leading, spacing: KumaSpacing.xs) {
                    HStack(spacing: KumaSpacing.sm) {
                        Text(aggregate.name)
                            .font(KumaTheme.Font.headline)
                            .foregroundStyle(KumaTheme.Color.textPrimary)

                        if let provider = aggregate.activeProvider {
                            Text(provider.providerType.displayName)
                                .font(KumaTheme.Font.caption)
                                .padding(.horizontal, KumaSpacing.xs)
                                .padding(.vertical, 2)
                                .background(KumaTheme.Color.surfaceBackground, in: RoundedRectangle(cornerRadius: 4))
                        }
                    }

                    if let provider = aggregate.activeProvider {
                        Text(provider.config.summaryDescription)
                            .font(KumaTheme.Font.caption)
                            .foregroundStyle(KumaTheme.Color.textSecondary)
                    }
                }

                Spacer()

                HStack(spacing: KumaSpacing.sm) {
                    statusPill

                    Button {
                        onToggleExecution()
                    } label: {
                        Image(systemName: aggregate.state.isRunning ? "stop.fill" : "play.fill")
                            .foregroundStyle(aggregate.state.isRunning ? KumaTheme.Color.statusStopped : KumaTheme.Color.statusRunning)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(aggregate.state.isRunning ? "Stop \(aggregate.name)" : "Start \(aggregate.name)")
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: KumaRadius.lg, style: .continuous)
                .strokeBorder(isSelected ? KumaTheme.Color.accent : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onSelect()
        }
    }

    private var statusPill: some View {
        Text(aggregate.state.titleText)
            .font(KumaTheme.Font.caption)
            .fontWeight(.medium)
            .foregroundStyle(aggregate.state.isRunning ? Color.white : KumaTheme.Color.textSecondary)
            .padding(.horizontal, KumaSpacing.sm)
            .padding(.vertical, 4)
            .background(
                aggregate.state.isRunning ? KumaTheme.Color.statusRunning : KumaTheme.Color.surfaceBackground,
                in: Capsule()
            )
    }
}

private extension ServiceExecutionState {
    var isRunning: Bool {
        if case .running = self { return true }
        return false
    }

    var titleText: String {
        switch self {
        case .stopped: return "Stopped"
        case .starting: return "Starting..."
        case .running: return "Running"
        case .stopping: return "Stopping..."
        case .failed: return "Failed"
        }
    }
}
