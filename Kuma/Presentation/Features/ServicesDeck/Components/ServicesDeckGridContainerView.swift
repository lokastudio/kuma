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
                    ServiceCardView(
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
