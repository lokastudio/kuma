//
//  KumaPickerField.swift
//  Kuma
//

import SwiftUI

/// A reusable dropdown picker component styled with KumaTheme tokens, supporting title, options list, inline validation, and accessibility.
public struct KumaPickerField<SelectionValue: Hashable & Identifiable>: View {
    let title: String?
    @Binding var selection: SelectionValue
    let options: [SelectionValue]
    let labelProvider: @MainActor @Sendable (SelectionValue) -> String
    let helpText: String?
    let errorMessage: String?
    let isDisabled: Bool

    public init(
        title: String? = nil,
        selection: Binding<SelectionValue>,
        options: [SelectionValue],
        labelProvider: @escaping @MainActor @Sendable (SelectionValue) -> String,
        helpText: String? = nil,
        errorMessage: String? = nil,
        isDisabled: Bool = false
    ) {
        self.title = title
        self._selection = selection
        self.options = options
        self.labelProvider = labelProvider
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

            HStack {
                Picker("", selection: $selection) {
                    ForEach(options) { option in
                        Text(labelProvider(option))
                            .tag(option)
                    }
                }
                .pickerStyle(.menu)
                .font(KumaFont.body)
                .disabled(isDisabled)
                .accessibilityLabel(title ?? "Select option")
            }
            .padding(.horizontal, KumaSpacing.xs)
            .padding(.vertical, KumaSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: KumaRadius.md, style: .continuous)
                    .fill(KumaColor.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: KumaRadius.md, style: .continuous)
                    .stroke(strokeColor, lineWidth: 1.0)
            )

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
        return KumaColor.border
    }
}

private struct DemoOption: Hashable, Identifiable {
    let id: String
    let name: String
}

#Preview("KumaPickerField - States") {
    let options = [
        DemoOption(id: "1", name: "Local Process Engine"),
        DemoOption(id: "2", name: "Docker Container Engine"),
        DemoOption(id: "3", name: "Kubernetes Port Forwarder")
    ]

    return VStack(spacing: KumaSpacing.lg) {
        KumaPickerField(
            title: "Provider Engine",
            selection: .constant(options[0]),
            options: options,
            labelProvider: { $0.name },
            helpText: "Select background execution engine."
        )
    }
    .padding(KumaSpacing.lg)
    .frame(width: 400)
    .background(KumaColor.windowBackground)
}
