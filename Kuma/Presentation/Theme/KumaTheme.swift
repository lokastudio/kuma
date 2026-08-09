import SwiftUI

/// Master Theme namespace for Kuma design system.
/// Bundles Spacing, Radii, Fonts, and Colors into a single type-safe interface.
public enum KumaTheme: Sendable {
    public typealias Spacing = KumaSpacing
    public typealias Radius = KumaRadius
    public typealias Font = KumaFont
    public typealias Color = KumaColor
}

// MARK: - Design Token Swatch Preview
#Preview("KumaTheme Swatch Catalog") {
    VStack(alignment: .leading, spacing: KumaTheme.Spacing.md) {
        Text("Kuma Design System Swatches")
            .font(KumaTheme.Font.title1)
            .foregroundColor(KumaTheme.Color.textPrimary)

        Divider()

        Group {
            Text("Execution States")
                .font(KumaTheme.Font.headline)

            HStack(spacing: KumaTheme.Spacing.sm) {
                stateBadge("Running", color: KumaTheme.Color.statusRunning)
                stateBadge("Stopped", color: KumaTheme.Color.statusStopped)
                stateBadge("Starting", color: KumaTheme.Color.statusStarting)
                stateBadge("Failed", color: KumaTheme.Color.statusFailed)
            }
        }

        Group {
            Text("Providers (8 Engines)")
                .font(KumaTheme.Font.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], alignment: .leading, spacing: KumaTheme.Spacing.xs) {
                providerChip("K8s", color: KumaTheme.Color.providerKubernetes)
                providerChip("Docker", color: KumaTheme.Color.providerDocker)
                providerChip("Podman", color: KumaTheme.Color.providerPodman)
                providerChip("Shell", color: KumaTheme.Color.providerShell)
                providerChip("SSH", color: KumaTheme.Color.providerSSH)
                providerChip("HTTP", color: KumaTheme.Color.providerHTTPCheck)
                providerChip("Tunnel", color: KumaTheme.Color.providerTunnel)
                providerChip("Monitor", color: KumaTheme.Color.providerProcessMonitor)
            }
        }

        Group {
            Text("Typography")
                .font(KumaTheme.Font.headline)

            VStack(alignment: .leading, spacing: KumaTheme.Spacing.xs) {
                Text("title1 (20pt Bold)").font(KumaTheme.Font.title1)
                Text("headline (14pt Semibold)").font(KumaTheme.Font.headline)
                Text("body (13pt Regular)").font(KumaTheme.Font.body)
                Text("kubectl get pods -n default").font(KumaTheme.Font.code)
            }
        }
    }
    .padding(KumaTheme.Spacing.lg)
    .background(KumaTheme.Color.surfaceBackground)
    .frame(width: 450)
}

@ViewBuilder
private func stateBadge(_ text: String, color: Color) -> some View {
    Text(text)
        .font(KumaTheme.Font.badge)
        .foregroundColor(.white)
        .padding(.horizontal, KumaTheme.Spacing.sm)
        .padding(.vertical, KumaTheme.Spacing.xs)
        .background(color)
        .kumaCornerRadius(KumaTheme.Radius.full)
}

@ViewBuilder
private func providerChip(_ text: String, color: Color) -> some View {
    Text(text)
        .font(KumaTheme.Font.badge)
        .foregroundColor(color)
        .padding(.horizontal, KumaTheme.Spacing.sm)
        .padding(.vertical, KumaTheme.Spacing.xs)
        .background(color.opacity(0.15))
        .kumaCornerRadius(KumaTheme.Radius.sm)
}
