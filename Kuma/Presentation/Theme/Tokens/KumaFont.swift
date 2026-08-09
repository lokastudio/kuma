import SwiftUI

/// Standardized typography tokens for Kuma.
/// Enforces type safety and consistency across headers, body text, and code monospaced displays.
public enum KumaFont: Sendable {
    /// Large section / page titles (20pt Bold)
    public static let title1: Font = .system(size: 20, weight: .bold, design: .default)
    /// Card / group titles (16pt Semibold)
    public static let title2: Font = .system(size: 16, weight: .semibold, design: .default)
    /// Section headers & important labels (14pt Medium)
    public static let headline: Font = .system(size: 14, weight: .semibold, design: .default)
    /// Field titles & secondary headers (13pt Medium)
    public static let subheadline: Font = .system(size: 13, weight: .medium, design: .default)
    /// Standard body text (13pt Regular)
    public static let body: Font = .system(size: 13, weight: .regular, design: .default)
    /// Captions, help text & inline validation errors (11pt Regular)
    public static let caption: Font = .system(size: 11, weight: .regular, design: .default)
    /// Port badges, status chips & micro labels (10pt Semibold)
    public static let badge: Font = .system(size: 10, weight: .semibold, design: .default)
    /// Standard Monospaced font for commands, paths, PIDs, and logs (12pt Monospaced)
    public static let code: Font = .system(size: 12, weight: .regular, design: .monospaced)
    /// Small Monospaced font for log streams & inline port URLs (10pt Monospaced)
    public static let codeSmall: Font = .system(size: 10, weight: .regular, design: .monospaced)
}
