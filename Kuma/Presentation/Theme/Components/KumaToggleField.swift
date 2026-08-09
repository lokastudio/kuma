//
//  KumaToggleField.swift
//  Kuma
//

import SwiftUI

/// A reusable toggle row component styled with KumaTheme tokens, supporting primary title, optional description, custom icon, and state switch.
public struct KumaToggleField: View {
    let title: String
    @Binding var isOn: Bool
    let description: String?
    let iconName: String?
    let isDisabled: Bool

    public init(
        title: String,
        isOn: Binding<Bool>,
        description: String? = nil,
        iconName: String? = nil,
        isDisabled: Bool = false
    ) {
        self.title = title
        self._isOn = isOn
        self.description = description
        self.iconName = iconName
        self.isDisabled = isDisabled
    }

    public var body: some View {
        HStack(spacing: KumaSpacing.md) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isOn ? KumaColor.accent : KumaColor.textSecondary)
                    .frame(width: 24, height: 24)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(KumaFont.body)
                    .fontWeight(.medium)
                    .foregroundColor(isDisabled ? KumaColor.textSecondary : KumaColor.textPrimary)

                if let description = description {
                    Text(description)
                        .font(KumaFont.caption)
                        .foregroundColor(KumaColor.textSecondary)
                }
            }

            Spacer(minLength: KumaSpacing.sm)

            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(KumaColor.accent)
                .disabled(isDisabled)
                .accessibilityLabel(title)
        }
        .padding(.horizontal, KumaSpacing.md)
        .padding(.vertical, KumaSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: KumaRadius.md, style: .continuous)
                .fill(KumaColor.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: KumaRadius.md, style: .continuous)
                .stroke(KumaColor.border, lineWidth: 1.0)
        )
    }
}

#Preview("KumaToggleField - States") {
    VStack(spacing: KumaSpacing.lg) {
        KumaToggleField(
            title: "Launch at Login",
            isOn: .constant(true),
            description: "Automatically start Kuma background engine on system launch.",
            iconName: "power"
        )

        KumaToggleField(
            title: "Auto-Reconnect Services",
            isOn: .constant(false),
            description: "Restores broken tunnel connections upon network recovery.",
            iconName: "arrow.triangle.2.circlepath"
        )
    }
    .padding(KumaSpacing.lg)
    .frame(width: 450)
    .background(KumaColor.windowBackground)
}
