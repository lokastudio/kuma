//
//  KumaTextField.swift
//  Kuma
//

import SwiftUI

/// A reusable FormKit input field styled with KumaTheme tokens, supporting titles, subtext, inline validation error messages, and dynamic focus rings.
public struct KumaTextField: View {
    let title: String?
    @Binding var text: String
    let placeholder: String
    let helpText: String?
    let errorMessage: String?
    let isDisabled: Bool

    @FocusState private var isFocused: Bool

    public init(
        title: String? = nil,
        text: Binding<String>,
        placeholder: String = "",
        helpText: String? = nil,
        errorMessage: String? = nil,
        isDisabled: Bool = false
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.helpText = helpText
        self.errorMessage = errorMessage
        self.isDisabled = isDisabled
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: KumaSpacing.xs) {
            if let title = title {
                Text(title)
                    .font(KumaFont.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(KumaColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
            }

            HStack(spacing: KumaSpacing.xs) {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .font(KumaFont.body)
                    .foregroundColor(isDisabled ? KumaColor.textSecondary : KumaColor.textPrimary)
                    .disabled(isDisabled)
                    .focused($isFocused)
                    .accessibilityLabel(title ?? placeholder)

                if !text.isEmpty && !isDisabled {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(KumaColor.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear text")
                }
            }
            .padding(.horizontal, KumaSpacing.sm)
            .padding(.vertical, KumaSpacing.xs + 2)
            .background(
                RoundedRectangle(cornerRadius: KumaRadius.md, style: .continuous)
                    .fill(KumaColor.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: KumaRadius.md, style: .continuous)
                    .stroke(strokeColor, lineWidth: isFocused ? 1.5 : 1.0)
            )
            .shadow(color: isFocused ? strokeColor.opacity(0.3) : .clear, radius: 3, x: 0, y: 0)

            if let errorMessage = errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(KumaFont.caption)
                    .foregroundColor(KumaColor.errorText)
            } else if let helpText = helpText, !helpText.isEmpty {
                Text(helpText)
                    .font(KumaFont.caption)
                    .foregroundColor(KumaColor.textSecondary)
            }
        }
    }

    private var strokeColor: Color {
        if errorMessage != nil && !(errorMessage?.isEmpty ?? true) {
            return KumaColor.errorText
        }
        if isFocused {
            return KumaColor.accent
        }
        return KumaColor.border
    }
}

#Preview("KumaTextField - States") {
    VStack(spacing: KumaSpacing.lg) {
        KumaTextField(
            title: "Service Name",
            text: .constant("forwarder-mongo-stage"),
            placeholder: "e.g. forwarder-mongo-stage",
            helpText: "Must be unique within workspace."
        )

        KumaTextField(
            title: "Remote Host",
            text: .constant(""),
            placeholder: "e.g. 127.0.0.1",
            errorMessage: "Host IP address cannot be blank."
        )

        KumaTextField(
            title: "Disabled Input",
            text: .constant("Readonly Value"),
            isDisabled: true
        )
    }
    .padding(KumaSpacing.lg)
    .frame(width: 400)
    .background(KumaColor.windowBackground)
}
