//
//  ServicesDeckView.swift
//  Kuma
//
//  Created for Task 7.5 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Primary Services Deck View displaying service aggregates in a filtered `LazyVStack` grid.
/// Supports real-time text searching, state filters, batch quick actions, and Auto-Context Follow.
@MainActor
public struct ServicesDeckView: View {
    public let selection: SidebarSelection?
    @Binding public var selectedServiceId: UUID?

    @Environment(ServiceStore.self) private var serviceStore

    @State private var searchText: String = ""
    @State private var selectedStateFilter: ServiceStateFilter = .all

    public init(
        selection: SidebarSelection?,
        selectedServiceId: Binding<UUID?>
    ) {
        self.selection = selection
        self._selectedServiceId = selectedServiceId
    }

    private var filteredAggregates: [ServiceAggregate] {
        serviceStore.aggregates.filter { aggregate in
            // 1. Sidebar selection filter
            let matchesSelection: Bool
            switch selection {
            case .allRunning:
                if case .running = aggregate.state { matchesSelection = true } else { matchesSelection = false }
            case .allServices, .none:
                matchesSelection = true
            case .provider(let type):
                matchesSelection = aggregate.activeProvider?.providerType == type
            case .customGroup:
                matchesSelection = true
            case .settings, .help:
                matchesSelection = false
            }
            guard matchesSelection else { return false }

            // 2. State filter
            let matchesState: Bool
            switch selectedStateFilter {
            case .all:
                matchesState = true
            case .running:
                if case .running = aggregate.state { matchesState = true } else { matchesState = false }
            case .stopped:
                if case .stopped = aggregate.state { matchesState = true } else { matchesState = false }
            case .failed:
                if case .failed = aggregate.state { matchesState = true } else { matchesState = false }
            }
            guard matchesState else { return false }

            // 3. Search query filter
            if searchText.isEmpty { return true }
            let query = searchText.lowercased()
            let nameMatch = aggregate.name.lowercased().contains(query)
            let providerMatch = aggregate.activeProvider?.config.summaryDescription.lowercased().contains(query) ?? false
            return nameMatch || providerMatch
        }
    }

    private var runningCount: Int {
        filteredAggregates.filter {
            if case .running = $0.state { return true }
            return false
        }.count
    }

    public var body: some View {
        VStack(spacing: 0) {
            ServicesDeckHeaderView(
                selection: selection,
                totalCount: filteredAggregates.count,
                runningCount: runningCount,
                onStartAll: {
                    Task {
                        for aggregate in filteredAggregates {
                            await serviceStore.startService(id: aggregate.id)
                        }
                    }
                },
                onStopAll: {
                    Task {
                        for aggregate in filteredAggregates {
                            await serviceStore.stopService(id: aggregate.id)
                        }
                    }
                }
            )

            ServicesDeckFilterBarView(
                searchText: $searchText,
                selectedStateFilter: $selectedStateFilter
            )

            Divider()
                .padding(.top, KumaSpacing.xs)

            if filteredAggregates.isEmpty {
                ServicesDeckEmptyStateView(
                    searchText: searchText,
                    selectedStateFilter: selectedStateFilter,
                    onResetFilters: {
                        searchText = ""
                        selectedStateFilter = .all
                    }
                )
            } else {
                ServicesDeckGridContainerView(
                    aggregates: filteredAggregates,
                    selectedServiceId: $selectedServiceId,
                    onToggleExecution: { aggregate in
                        Task {
                            if case .running = aggregate.state {
                                await serviceStore.stopService(id: aggregate.id)
                            } else {
                                await serviceStore.startService(id: aggregate.id)
                            }
                        }
                    }
                )
            }
        }
        .background(KumaTheme.Color.windowBackground)
    }
}

#Preview("ServicesDeckView") {
    ServicesDeckView(
        selection: .allServices,
        selectedServiceId: .constant(nil)
    )
    .environment(ServiceStore.mock)
    .frame(width: 700, height: 600)
}
