//
//  KumaCardContainer.swift
//  Kuma
//

import SwiftUI

/// Container wrapper providing uniform card styling, subtle borders, and optional hover feedback using KumaTheme.
@MainActor
public struct KumaCardContainer<Content: View>: View {
    private let padding: CGFloat
    private let isInteractive: Bool
    private let content: Content

    @State private var isHovered: Bool = false

    public init(
        padding: CGFloat = KumaSpacing.md,
        isInteractive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.isInteractive = isInteractive
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: KumaRadius.lg, style: .continuous)
                    .fill(isHovered && isInteractive ? KumaColor.cardBackground.opacity(0.8) : KumaColor.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: KumaRadius.lg, style: .continuous)
                    .strokeBorder(isHovered && isInteractive ? Color.accentColor : KumaColor.cardBorder, lineWidth: isHovered && isInteractive ? 1.0 : 0.5)
            )
            .shadow(
                color: isHovered && isInteractive ? Color.black.opacity(0.15) : Color.clear,
                radius: 4,
                x: 0,
                y: 2
            )
            .onHover { hovering in
                guard isInteractive else { return }
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
    }
}

#Preview {
    VStack(spacing: KumaSpacing.md) {
        KumaCardContainer(isInteractive: true) {
            HStack {
                VStack(alignment: .leading, spacing: KumaSpacing.xs) {
                    Text("Interactive Card")
                        .font(KumaFont.headline)
                        .foregroundColor(KumaColor.textPrimary)
                    Text("Hover over me for focus feedback.")
                        .font(KumaFont.caption)
                        .foregroundColor(KumaColor.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(KumaColor.textMuted)
            }
        }

        KumaCardContainer(isInteractive: false) {
            Text("Static Card Container Content")
                .font(KumaFont.body)
                .foregroundColor(KumaColor.textPrimary)
        }
    }
    .padding()
    .frame(width: 400)
    .background(KumaColor.surfaceBackground)
}
