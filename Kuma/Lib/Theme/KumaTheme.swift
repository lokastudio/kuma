//
//  KumaTheme.swift
//  Kuma
//
//  Tokenized Design System for Kuma Native macOS App.
//  Zero magic numbers rule enforcement.
//

import SwiftUI

public enum KumaSpacing {
    /// 4pt
    public static let xs: CGFloat = 4
    /// 8pt
    public static let sm: CGFloat = 8
    /// 12pt
    public static let md: CGFloat = 12
    /// 16pt
    public static let lg: CGFloat = 16
    /// 24pt
    public static let xl: CGFloat = 24
    /// 32pt
    public static let xxl: CGFloat = 32
}

public enum KumaRadius {
    /// 6pt
    public static let sm: CGFloat = 6
    /// 10pt
    public static let md: CGFloat = 10
    /// 14pt
    public static let lg: CGFloat = 14
    /// 20pt
    public static let xl: CGFloat = 20
}

public enum KumaFont {
    public static let title = Font.system(size: 18, weight: .bold, design: .default)
    public static let body = Font.system(size: 13, weight: .regular, design: .default)
    public static let subheadline = Font.system(size: 11, weight: .medium, design: .default)
    public static let caption = Font.system(size: 10, weight: .regular, design: .default)
    public static let monospacedCode = Font.system(size: 12, weight: .regular, design: .monospaced)
}

public enum KumaTheme {
    public enum ProviderTints {
        public static let kube = Color.blue
        public static let docker = Color.cyan
        public static let podman = Color.purple
        public static let shell = Color.orange
        public static let ssh = Color.indigo
    }
    
    public enum StatusColors {
        public static let running = Color.green
        public static let stopped = Color.secondary
        public static let starting = Color.orange
        public static let failed = Color.red
        public static let disabled = Color.secondary.opacity(0.5)
    }
}
