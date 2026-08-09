//
//  InspectorLogStreamView.swift
//  Kuma
//
//  Created for Task 7.7 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Component rendering live streaming log buffer with auto-scroll and quick log management.
@MainActor
public struct InspectorLogStreamView: View {
    public let logs: [String]
    public let onClearLogs: () -> Void

    @State private var autoScrollEnabled = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        logs: [String],
        onClearLogs: @escaping () -> Void
    ) {
        self.logs = logs
        self.onClearLogs = onClearLogs
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: KumaSpacing.xs) {
            HStack {
                KumaSectionHeader(title: "LIVE LOGS STREAM", subtitle: "Real-time output viewer")

                Spacer()

                Button(action: onClearLogs) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundStyle(KumaTheme.Color.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear logs")

                Button {
                    autoScrollEnabled.toggle()
                } label: {
                    Image(systemName: autoScrollEnabled ? "arrow.down.circle.fill" : "arrow.down.circle")
                        .font(.system(size: 11))
                        .foregroundStyle(autoScrollEnabled ? KumaTheme.Color.accent : KumaTheme.Color.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Toggle auto-scroll logs")
            }

            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        if logs.isEmpty {
                            Text("No log stream output recorded yet.")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(KumaTheme.Color.textMuted)
                                .padding(KumaSpacing.sm)
                        } else {
                            ForEach(Array(logs.enumerated()), id: \.offset) { index, line in
                                Text(line)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(KumaTheme.Color.textPrimary)
                                    .id(index)
                            }
                        }
                    }
                    .padding(KumaSpacing.xs)
                }
                .background(
                    KumaTheme.Color.cardBackground,
                    in: RoundedRectangle(cornerRadius: KumaRadius.md, style: .continuous)
                )
                .onChange(of: logs.count) { _, newCount in
                    if autoScrollEnabled && newCount > 0 {
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.1)) {
                            proxy.scrollTo(newCount - 1, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, KumaSpacing.md)
    }
}
