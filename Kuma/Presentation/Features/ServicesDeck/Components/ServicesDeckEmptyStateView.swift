//
//  ServicesDeckEmptyStateView.swift
//  Kuma
//
//  Created for Task 7.5 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Empty state placeholder for `ServicesDeckView` when no services match active filter criteria.
@MainActor
public struct ServicesDeckEmptyStateView: View {
    public let searchText: String
    public let selectedStateFilter: ServiceStateFilter
    public let onResetFilters: () -> Void

    public init(
        searchText: String,
        selectedStateFilter: ServiceStateFilter,
        onResetFilters: @escaping () -> Void
    ) {
        self.searchText = searchText
        self.selectedStateFilter = selectedStateFilter
        self.onResetFilters = onResetFilters
    }

    public var body: some View {
        VStack(spacing: KumaSpacing.md) {
            Image(systemName: "tray.fill")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(KumaTheme.Color.textMuted)

            VStack(spacing: KumaSpacing.xs) {
                Text(titleText)
                    .font(KumaTheme.Font.headline)
                    .foregroundStyle(KumaTheme.Color.textPrimary)

                Text(descriptionText)
                    .font(KumaTheme.Font.subheadline)
                    .foregroundStyle(KumaTheme.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 340)
            }

            if !searchText.isEmpty || selectedStateFilter != .all {
                Button("Reset Search & Filters") {
                    onResetFilters()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityLabel("Reset search and filters")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(KumaSpacing.xl)
    }

    private var titleText: String {
        if !searchText.isEmpty {
            return "No matching services"
        } else if selectedStateFilter != .all {
            return "No \(selectedStateFilter.rawValue.lowercased()) services"
        } else {
            return "No services configured"
        }
    }

    private var descriptionText: String {
        if !searchText.isEmpty {
            return "No services matched '\(searchText)'. Try adjusting your query or resetting filters."
        } else if selectedStateFilter != .all {
            return "There are currently no services with status '\(selectedStateFilter.rawValue)' in this view."
        } else {
            return "Add your first service or sync Kubernetes configuration to get started."
        }
    }
}

#Preview("ServicesDeckEmptyStateView") {
    ServicesDeckEmptyStateView(
        searchText: "postgres",
        selectedStateFilter: .running,
        onResetFilters: {}
    )
    .frame(width: 500, height: 350)
    .background(KumaTheme.Color.surfaceBackground)
}
