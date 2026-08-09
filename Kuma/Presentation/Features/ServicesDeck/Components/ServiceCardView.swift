//
//  ServiceCardView.swift
//  Kuma
//
//  Created for Task 7.6 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Primary service card component displaying aggregate details, provider type, port badges, and quick actions.
@MainActor
public struct ServiceCardView: View {
    public let aggregate: ServiceAggregate
    public let isSelected: Bool
    public let onSelect: () -> Void
    public let onToggleExecution: () -> Void

    @State private var isHovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        aggregate: ServiceAggregate,
        isSelected: Bool,
        onSelect: @escaping () -> Void,
        onToggleExecution: @escaping () -> Void
    ) {
        self.aggregate = aggregate
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.onToggleExecution = onToggleExecution
    }

    public var body: some View {
        KumaCardContainer(isInteractive: true) {
            VStack(alignment: .leading, spacing: KumaSpacing.sm) {
                ServiceCardHeaderView(
                    title: aggregate.name,
                    providerType: aggregate.activeProvider?.providerType,
                    state: aggregate.state
                )

                if let summary = aggregate.activeProvider?.config.summaryDescription, !summary.isEmpty {
                    Text(summary)
                        .font(KumaTheme.Font.caption)
                        .foregroundStyle(KumaTheme.Color.textSecondary)
                        .lineLimit(1)
                }

                HStack(alignment: .center) {
                    ServiceCardPortBadgesView(portMappings: aggregate.portMappings)

                    Spacer()

                    ServiceCardQuickActionsView(
                        serviceName: aggregate.name,
                        state: aggregate.state,
                        onToggleExecution: onToggleExecution
                    )
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: KumaRadius.lg, style: .continuous)
                .strokeBorder(isSelected ? KumaTheme.Color.accent : (isHovered ? KumaTheme.Color.cardBorder : Color.clear), lineWidth: isSelected ? 2 : 1)
        )
        .scaleEffect(isHovered && !reduceMotion ? 1.005 : 1.0)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onSelect()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(aggregate.name), \(aggregate.stateText)")
    }
}

private extension ServiceAggregate {
    var stateText: String {
        switch state {
        case .stopped: return "Stopped"
        case .starting: return "Starting"
        case .running: return "Running"
        case .stopping: return "Stopping"
        case .failed: return "Failed"
        }
    }
}
