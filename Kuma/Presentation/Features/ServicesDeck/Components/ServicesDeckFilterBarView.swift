//
//  ServicesDeckFilterBarView.swift
//  Kuma
//
//  Created for Task 7.5 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Filter bar for `ServicesDeckView` containing search input and execution state filter pills.
@MainActor
public struct ServicesDeckFilterBarView: View {
    @Binding public var searchText: String
    @Binding public var selectedStateFilter: ServiceStateFilter

    public init(
        searchText: Binding<String>,
        selectedStateFilter: Binding<ServiceStateFilter>
    ) {
        self._searchText = searchText
        self._selectedStateFilter = selectedStateFilter
    }

    public var body: some View {
        HStack(spacing: KumaSpacing.md) {
            KumaTextField(
                text: $searchText,
                placeholder: "Search services e.g. forwarder-mongo-stage..."
            )
            .frame(maxWidth: .infinity)

            Picker("State Filter", selection: $selectedStateFilter) {
                ForEach(ServiceStateFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 260)
            .accessibilityLabel("Filter services by state")
        }
        .padding(.horizontal, KumaSpacing.md)
        .padding(.vertical, KumaSpacing.xs)
    }
}

#Preview("ServicesDeckFilterBarView") {
    VStack {
        ServicesDeckFilterBarView(
            searchText: .constant(""),
            selectedStateFilter: .constant(.all)
        )
    }
    .background(KumaTheme.Color.surfaceBackground)
    .frame(width: 650)
}
