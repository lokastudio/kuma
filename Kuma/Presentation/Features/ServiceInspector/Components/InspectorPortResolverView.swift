//
//  InspectorPortResolverView.swift
//  Kuma
//
//  Created for Task 7.7 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Component displaying port mappings, conflict badges, 1-click copy local URLs, and interactive free-port resolution.
@MainActor
public struct InspectorPortResolverView: View {
    public let portMappings: [PortMapping]
    public let onFreePortRequested: (PortMapping) -> Void

    @State private var copiedPortId: UUID? = nil

    public init(
        portMappings: [PortMapping],
        onFreePortRequested: @escaping (PortMapping) -> Void
    ) {
        self.portMappings = portMappings
        self.onFreePortRequested = onFreePortRequested
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: KumaSpacing.xs) {
            KumaSectionHeader(title: "PORT MAPPINGS", subtitle: "Local forwarder mappings")

            if portMappings.isEmpty {
                Text("No active port mappings (e.g. 8080:80)")
                    .font(KumaTheme.Font.caption)
                    .foregroundStyle(KumaTheme.Color.textSecondary)
                    .padding(KumaSpacing.sm)
            } else {
                VStack(spacing: KumaSpacing.xs) {
                    ForEach(portMappings) { mapping in
                        HStack(spacing: KumaSpacing.sm) {
                            Button {
                                copyToClipboard(mapping)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: copiedPortId == mapping.id ? "checkmark" : "doc.on.doc")
                                        .font(.system(size: 10, weight: .bold))
                                    Text("localhost:\(mapping.localPort)")
                                        .font(KumaTheme.Font.caption)
                                        .fontWeight(.bold)
                                }
                                .foregroundStyle(copiedPortId == mapping.id ? KumaTheme.Color.statusRunning : KumaTheme.Color.textPrimary)
                                .padding(.horizontal, KumaSpacing.xs)
                                .padding(.vertical, 4)
                                .background(
                                    KumaTheme.Color.surfaceBackground,
                                    in: RoundedRectangle(cornerRadius: KumaRadius.sm, style: .continuous)
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Copy localhost:\(mapping.localPort)")

                            Image(systemName: "arrow.right")
                                .font(.system(size: 10))
                                .foregroundStyle(KumaTheme.Color.textMuted)

                            Text("\(mapping.remotePort)")
                                .font(KumaTheme.Font.caption)
                                .foregroundStyle(KumaTheme.Color.textSecondary)

                            Spacer()

                            Button {
                                onFreePortRequested(mapping)
                            } label: {
                                Text("Auto-Free Port")
                                    .font(KumaTheme.Font.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(KumaTheme.Color.accent)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Auto free port for \(mapping.localPort)")
                        }
                        .padding(KumaSpacing.xs)
                    }
                }
            }
        }
        .padding(.horizontal, KumaSpacing.md)
    }

    private func copyToClipboard(_ mapping: PortMapping) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("http://localhost:\(mapping.localPort)", forType: .string)
        copiedPortId = mapping.id

        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if copiedPortId == mapping.id {
                copiedPortId = nil
            }
        }
    }
}
