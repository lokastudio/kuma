//
//  KumaSecureField.swift
//  Kuma
//

import SwiftUI

/// A reusable secure text input field styled with KumaTheme tokens, supporting show/hide password toggle, inline validation errors, and focus ring styling.
public struct KumaSecureField: View {
    let title: String?
    @Binding var text: String
    let placeholder: String
    let helpText: String?
    let errorMessage: String?
    let isDisabled: Bool

    @State private var isSecured: Bool = true
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
                Group {
                    if isSecured {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .textFieldStyle(.plain)
                .font(KumaFont.body)
                .foregroundColor(isDisabled ? KumaColor.textSecondary : KumaColor.textPrimary)
                .disabled(isDisabled)
                .focused($isFocused)
                .accessibilityLabel(title ?? placeholder)

                Button(action: { isSecured.toggle() }) {
                    Image(systemName: isSecured ? "eye" : "eye.slash")
                        .font(.system(size: 13))
                        .foregroundColor(KumaColor.textSecondary)
                }
                .buttonStyle(.plain)
                .disabled(isDisabled)
                .accessibilityLabel(isSecured ? "Show password" : "Hide password")
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

#Preview("KumaSecureField - States") {
    VStack(spacing: KumaSpacing.lg) {
        KumaSecureField(
            title: "Vault Passphrase",
            text: .constant("SuperSecretPassphrase123"),
            placeholder: "e.g. secret-token",
            helpText: "Stored securely in AES-256 encrypted vault."
        )

        KumaSecureField(
            title: "SSH Key Password",
            text: .constant(""),
            placeholder: "e.g. pass123",
            errorMessage: "Password cannot be empty for protected keys."
        )
    }
    .padding(KumaSpacing.lg)
    .frame(width: 400)
    .background(KumaColor.windowBackground)
}
