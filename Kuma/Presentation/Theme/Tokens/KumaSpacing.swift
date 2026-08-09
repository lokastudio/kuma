import SwiftUI

/// Standardized layout spacing tokens for Kuma.
/// Eliminates magic numbers across views and forms.
public enum KumaSpacing: Sendable {
    /// 4pt micro spacing
    public static let xs: CGFloat = 4
    /// 8pt small spacing
    public static let sm: CGFloat = 8
    /// 12pt medium spacing
    public static let md: CGFloat = 12
    /// 16pt large spacing
    public static let lg: CGFloat = 16
    /// 24pt extra large spacing
    public static let xl: CGFloat = 24
    /// 32pt double extra large spacing
    public static let xxl: CGFloat = 32
}
