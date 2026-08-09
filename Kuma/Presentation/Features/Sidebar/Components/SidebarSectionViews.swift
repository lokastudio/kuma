//
//  SidebarSectionViews.swift
//  Kuma
//
//  Created for Task 7.4 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

// MARK: - Master Views Section

public struct SidebarMasterSectionView: View {
    @Binding public var selection: SidebarSelection?
    @Environment(ServiceStore.self) private var serviceStore

    public init(selection: Binding<SidebarSelection?>) {
        self._selection = selection
    }

    public var body: some View {
        Section("Master Views") {
            Button {
                selection = .allRunning
            } label: {
                Label {
                    HStack {
                        Text("Active Services")
                            .font(KumaTheme.Font.body)
                            .foregroundStyle(KumaTheme.Color.textPrimary)
                        Spacer()
                        if serviceStore.runningCount > 0 {
                            Text("\(serviceStore.runningCount)")
                                .font(KumaTheme.Font.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, KumaSpacing.xs)
                                .padding(.vertical, 2)
                                .background(KumaTheme.Color.statusRunning, in: Capsule())
                        }
                    }
                } icon: {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(KumaTheme.Color.statusRunning)
                }
            }
            .tag(SidebarSelection.allRunning)
            .accessibilityLabel("Active Running Services, \(serviceStore.runningCount) running")

            Button {
                selection = .allServices
            } label: {
                Label {
                    HStack {
                        Text("All Services Deck")
                            .font(KumaTheme.Font.body)
                            .foregroundStyle(KumaTheme.Color.textPrimary)
                        Spacer()
                        Text("\(serviceStore.aggregates.count)")
                            .font(KumaTheme.Font.caption)
                            .foregroundStyle(KumaTheme.Color.textMuted)
                    }
                } icon: {
                    Image(systemName: "square.grid.2x2")
                        .foregroundStyle(KumaTheme.Color.textSecondary)
                }
            }
            .tag(SidebarSelection.allServices)
            .accessibilityLabel("All Services Deck, \(serviceStore.aggregates.count) total")
        }
    }
}

// MARK: - Smart Provider Filters Section

public struct SidebarProviderSectionView: View {
    @Binding public var selection: SidebarSelection?
    @Environment(ServiceStore.self) private var serviceStore

    public init(selection: Binding<SidebarSelection?>) {
        self._selection = selection
    }

    private let providerTypes: [ProviderType] = [
        .kubePortForward,
        .docker,
        .shell,
        .ssh
    ]

    public var body: some View {
        Section("By Active Provider") {
            ForEach(providerTypes, id: \.self) { type in
                let count = serviceStore.count(for: type)
                Button {
                    selection = .provider(type)
                } label: {
                    Label {
                        HStack {
                            Text(type.displayName)
                                .font(KumaTheme.Font.body)
                                .foregroundStyle(KumaTheme.Color.textPrimary)
                            Spacer()
                            if count > 0 {
                                Text("\(count)")
                                    .font(KumaTheme.Font.caption)
                                    .foregroundStyle(KumaTheme.Color.textSecondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(KumaTheme.Color.cardBackground, in: Capsule())
                            }
                        }
                    } icon: {
                        Image(systemName: type.systemImage)
                            .foregroundStyle(KumaTheme.Color.forProviderKey(type.rawValue))
                    }
                }
                .tag(SidebarSelection.provider(type))
                .accessibilityLabel("\(type.displayName), \(count) services")
            }
        }
    }
}

// MARK: - Favorites Section

public struct SidebarFavoritesSectionView: View {
    @Environment(ServiceStore.self) private var serviceStore

    public init() {}

    private var favoriteAggregates: [ServiceAggregate] {
        serviceStore.aggregates.filter(\.isFavorite)
    }

    public var body: some View {
        if !favoriteAggregates.isEmpty {
            Section("Favorites") {
                ForEach(favoriteAggregates) { agg in
                    Label {
                        HStack {
                            Text(agg.name)
                                .font(KumaTheme.Font.body)
                                .foregroundStyle(KumaTheme.Color.textPrimary)
                            Spacer()
                            Circle()
                                .fill(statusColor(for: agg.state))
                                .frame(width: 7, height: 7)
                        }
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.yellow)
                    }
                }
            }
        }
    }

    private func statusColor(for state: ServiceExecutionState) -> Color {
        KumaTheme.Color.forState(state)
    }
}

