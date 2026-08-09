//
//  ServicesDeckHeaderView.swift
//  Kuma
//
//  Created for Task 7.5 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Header view for `ServicesDeckView` displaying title, subtitle, count badge, and batch quick actions.
@MainActor
public struct ServicesDeckHeaderView: View {
    public let selection: SidebarSelection?
    public let totalCount: Int
    public let runningCount: Int
    public let onStartAll: () -> Void
    public let onStopAll: () -> Void

    public init(
        selection: SidebarSelection?,
        totalCount: Int,
        runningCount: Int,
        onStartAll: @escaping () -> Void,
        onStopAll: @escaping () -> Void
    ) {
        self.selection = selection
        self.totalCount = totalCount
        self.runningCount = runningCount
        self.onStartAll = onStartAll
        self.onStopAll = onStopAll
    }

    private var titleText: String {
        selection?.title ?? "All Services"
    }

    private var subtitleText: String {
        "Showing \(totalCount) service\(totalCount == 1 ? "" : "s") • \(runningCount) running"
    }

    public var body: some View {
        KumaSectionHeader(
            title: titleText,
            subtitle: subtitleText
        ) {
            HStack(spacing: KumaSpacing.sm) {
                Button {
                    onStartAll()
                } label: {
                    Label("Start All", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(KumaTheme.Color.statusRunning)
                .controlSize(.small)
                .disabled(totalCount == 0)
                .accessibilityLabel("Start all matching services")

                Button {
                    onStopAll()
                } label: {
                    Label("Stop All", systemImage: "stop.fill")
                }
                .buttonStyle(.bordered)
                .tint(KumaTheme.Color.statusStopped)
                .controlSize(.small)
                .disabled(runningCount == 0)
                .accessibilityLabel("Stop all running services")
            }
        }
        .padding(.horizontal, KumaSpacing.md)
        .padding(.top, KumaSpacing.md)
        .padding(.bottom, KumaSpacing.xs)
    }
}

#Preview("ServicesDeckHeaderView") {
    VStack {
        ServicesDeckHeaderView(
            selection: .allServices,
            totalCount: 5,
            runningCount: 2,
            onStartAll: {},
            onStopAll: {}
        )
    }
    .background(KumaTheme.Color.surfaceBackground)
    .frame(width: 600)
}
