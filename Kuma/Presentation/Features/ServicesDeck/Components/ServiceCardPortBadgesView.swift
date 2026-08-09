//
//  ServiceCardPortBadgesView.swift
//  Kuma
//
//  Created for Task 7.6 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI
import AppKit

/// Displays service port mappings with 1-click copy support to system pasteboard.
@MainActor
public struct ServiceCardPortBadgesView: View {
    public let portMappings: [PortMapping]
    @State private var copiedPortId: UUID? = nil

    public init(portMappings: [PortMapping]) {
        self.portMappings = portMappings
    }

    public var body: some View {
        if !portMappings.isEmpty {
            HStack(spacing: KumaSpacing.xs) {
                ForEach(portMappings) { mapping in
                    portBadge(for: mapping)
                }
            }
        }
    }

    private func portBadge(for mapping: PortMapping) -> some View {
        let isCopied = copiedPortId == mapping.id
        let label = "localhost:\(mapping.localPort)"

        return Button {
            copyToClipboard(url: label, id: mapping.id)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 9, weight: .bold))

                Text(label)
                    .font(KumaTheme.Font.caption)
                    .monospacedDigit()
            }
            .foregroundStyle(isCopied ? KumaTheme.Color.accent : KumaTheme.Color.textSecondary)
            .padding(.horizontal, KumaSpacing.xs)
            .padding(.vertical, 3)
            .background(
                KumaTheme.Color.surfaceBackground,
                in: RoundedRectangle(cornerRadius: KumaRadius.sm, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Copy \(label) to clipboard")
        .accessibilityHint("Copies the local service URL to system clipboard")
    }

    private func copyToClipboard(url: String, id: UUID) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("http://\(url)", forType: .string)

        withAnimation(.easeOut(duration: 0.15)) {
            copiedPortId = id
        }

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            if copiedPortId == id {
                withAnimation(.easeIn(duration: 0.15)) {
                    copiedPortId = nil
                }
            }
        }
    }
}
