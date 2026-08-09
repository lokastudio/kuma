import SwiftUI

/// Standardized corner radius tokens for Kuma.
/// Always uses continuous corner curve styling.
public enum KumaRadius: Sendable {
    /// 4pt radius (subtle badge/tag)
    public static let xs: CGFloat = 4
    /// 6pt radius (buttons/inputs)
    public static let sm: CGFloat = 6
    /// 8pt radius (cards/containers)
    public static let md: CGFloat = 8
    /// 12pt radius (popovers/modals)
    public static let lg: CGFloat = 12
    /// 16pt radius (hero cards/panels)
    public static let xl: CGFloat = 16
    /// Fully rounded pill radius
    public static let full: CGFloat = 9999
}

public extension View {
    /// Clips the view using a KumaRadius token with continuous corner curve style.
    func kumaCornerRadius(_ radius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}
