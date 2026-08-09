//
//  ServiceCardQuickActionsView.swift
//  Kuma
//
//  Created for Task 7.6 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Houses action triggers (Start/Stop toggle execution) with accessibility support.
@MainActor
public struct ServiceCardQuickActionsView: View {
    public let serviceName: String
    public let state: ServiceExecutionState
    public let onToggleExecution: () -> Void

    public init(
        serviceName: String,
        state: ServiceExecutionState,
        onToggleExecution: @escaping () -> Void
    ) {
        self.serviceName = serviceName
        self.state = state
        self.onToggleExecution = onToggleExecution
    }

    public var body: some View {
        HStack(spacing: KumaSpacing.xs) {
            Button {
                onToggleExecution()
            } label: {
                HStack(spacing: 4) {
                    if state.isTransitioning {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: isRunning ? "square.fill" : "play.fill")
                            .font(.system(size: 11, weight: .bold))
                    }

                    Text(isRunning ? "Stop" : "Start")
                        .font(KumaTheme.Font.caption)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(isRunning ? KumaTheme.Color.statusStopped : KumaTheme.Color.statusRunning)
                .padding(.horizontal, KumaSpacing.sm)
                .padding(.vertical, 6)
                .background(
                    (isRunning ? KumaTheme.Color.statusStopped : KumaTheme.Color.statusRunning).opacity(0.12),
                    in: RoundedRectangle(cornerRadius: KumaRadius.md, style: .continuous)
                )
            }
            .buttonStyle(.plain)
            .disabled(state.isTransitioning)
            .accessibilityLabel(isRunning ? "Stop \(serviceName)" : "Start \(serviceName)")
            .accessibilityHint("Toggles service execution state")
        }
    }

    private var isRunning: Bool {
        if case .running = state { return true }
        return false
    }
}
