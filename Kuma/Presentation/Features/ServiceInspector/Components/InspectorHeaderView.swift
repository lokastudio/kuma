//
//  InspectorHeaderView.swift
//  Kuma
//
//  Created for Task 7.7 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Header component for ServiceInspectorView displaying title, status, start/stop trigger, and close button.
@MainActor
public struct InspectorHeaderView: View {
    public let title: String
    public let state: ServiceExecutionState
    public let onToggleExecution: () -> Void
    public let onClose: () -> Void

    public init(
        title: String,
        state: ServiceExecutionState,
        onToggleExecution: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        self.title = title
        self.state = state
        self.onToggleExecution = onToggleExecution
        self.onClose = onClose
    }

    public var body: some View {
        HStack(spacing: KumaSpacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(KumaTheme.Font.title1)
                    .fontWeight(.bold)
                    .foregroundStyle(KumaTheme.Color.textPrimary)
                    .lineLimit(1)

                Text(stateSubtitle)
                    .font(KumaTheme.Font.caption)
                    .foregroundStyle(KumaTheme.Color.textSecondary)
            }

            Spacer()

            Button(action: onToggleExecution) {
                HStack(spacing: 4) {
                    Image(systemName: isRunning ? "stop.fill" : "play.fill")
                        .font(.system(size: 11, weight: .bold))
                    Text(isRunning ? "Stop" : "Start")
                        .font(KumaTheme.Font.body)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, KumaSpacing.sm)
                .padding(.vertical, 6)
                .background(
                    isRunning ? KumaTheme.Color.statusStopped.opacity(0.85) : KumaTheme.Color.accent,
                    in: RoundedRectangle(cornerRadius: KumaRadius.md, style: .continuous)
                )
                .foregroundStyle(Color.white)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isRunning ? "Stop service \(title)" : "Start service \(title)")

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(KumaTheme.Color.textMuted)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close inspector panel")
        }
        .padding(KumaSpacing.md)
        .background(KumaTheme.Color.surfaceBackground)
    }

    private var isRunning: Bool {
        if case .running = state { return true }
        return false
    }

    private var stateSubtitle: String {
        switch state {
        case .stopped:
            return "Service is inactive"
        case .starting(let progress):
            return "Starting: \(progress)"
        case .running(let pid, let port):
            return "Running (PID \(pid), Port \(port))"
        case .stopping:
            return "Stopping service..."
        case .failed(let error):
            return "Failed: \(error)"
        }
    }
}
