import SwiftUI

/// Semantic color tokens for Kuma.
/// Harmonized for dark/light mode and macOS native glassmorphism.
public enum KumaColor: Sendable {
    // MARK: - Surfaces & Backgrounds
    /// Primary background surface
    public static let surfaceBackground = Color(nsColor: .windowBackgroundColor)
    /// Card background surface
    public static let cardBackground = Color(nsColor: .controlBackgroundColor)
    /// Card subtle border color
    public static let cardBorder = Color.primary.opacity(0.1)
    /// Divider line color
    public static let divider = Color.primary.opacity(0.08)

    // MARK: - Typography Colors
    /// Primary high-contrast text color
    public static let textPrimary = Color.primary
    /// Secondary medium-contrast text color
    public static let textSecondary = Color.secondary
    /// Muted caption text color
    public static let textMuted = Color.secondary.opacity(0.7)

    // MARK: - Execution State Colors
    /// Service running state color (Emerald)
    public static let statusRunning = Color.green
    /// Service stopped state color (Slate/Gray)
    public static let statusStopped = Color.gray
    /// Service starting / stopping state color (Amber)
    public static let statusStarting = Color.orange
    /// Service stopping state color (Amber)
    public static let statusStopping = Color.orange
    /// Service failed state color (Rose/Red)
    public static let statusFailed = Color.red

    // MARK: - Provider Badge Colors
    /// Kubernetes provider color (Blue)
    public static let providerKubernetes = Color.blue
    /// Docker Compose provider color (Cyan)
    public static let providerDocker = Color.cyan
    /// Podman provider color (Purple)
    public static let providerPodman = Color.purple
    /// Shell Script provider color (Teal)
    public static let providerShell = Color.teal
    /// SSH Tunnel provider color (Indigo)
    public static let providerSSH = Color.indigo
    /// HTTP Check provider color (Green)
    public static let providerHTTPCheck = Color.green
    /// Cloudflare Tunnel provider color (Orange)
    public static let providerTunnel = Color.orange
    /// Process Monitor provider color (Mint)
    public static let providerProcessMonitor = Color.mint

    // MARK: - Domain Dynamic Mapping Helpers
    /// Returns the semantic color corresponding to a `ServiceExecutionState`.
    public static func forState(_ state: ServiceExecutionState) -> Color {
        switch state {
        case .running:
            return statusRunning
        case .stopped:
            return statusStopped
        case .starting:
            return statusStarting
        case .stopping:
            return statusStopping
        case .failed:
            return statusFailed
        }
    }

    /// Returns the provider badge color corresponding to a provider type identifier key.
    public static func forProviderKey(_ key: String) -> Color {
        switch key.lowercased() {
        case "kubernetes", "k8s":
            return providerKubernetes
        case "docker", "docker-compose":
            return providerDocker
        case "podman":
            return providerPodman
        case "shell", "bash":
            return providerShell
        case "ssh":
            return providerSSH
        case "http", "httpcheck":
            return providerHTTPCheck
        case "tunnel", "cloudflare":
            return providerTunnel
        case "process", "processmonitor", "monitor":
            return providerProcessMonitor
        default:
            return textSecondary
        }
    }
}
