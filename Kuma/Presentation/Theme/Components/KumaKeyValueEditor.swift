//
//  KumaKeyValueEditor.swift
//  Kuma
//

import SwiftUI

/// Pure domain helper item representing a key-value dictionary row.
public struct KumaKeyValuePair: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var key: String
    public var value: String

    public init(id: UUID = UUID(), key: String, value: String) {
        self.id = id
        self.key = key
        self.value = value
    }
}

/// FormKit editor component for managing key-value environment variables or headers.
public struct KumaKeyValueEditor: View {
    let title: String?
    @Binding var pairs: [KumaKeyValuePair]
    let keyPlaceholder: String
    let valuePlaceholder: String
    let helpText: String?
    let errorMessage: String?
    let isDisabled: Bool

    @State private var newKey: String = ""
    @State private var newValue: String = ""

    public init(
        title: String? = "Environment Variables",
        pairs: Binding<[KumaKeyValuePair]>,
        keyPlaceholder: String = "KEY (e.g. MONGO_URI)",
        valuePlaceholder: String = "VALUE",
        helpText: String? = nil,
        errorMessage: String? = nil,
        isDisabled: Bool = false
    ) {
        self.title = title
        self._pairs = pairs
        self.keyPlaceholder = keyPlaceholder
        self.valuePlaceholder = valuePlaceholder
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

            VStack(spacing: KumaSpacing.xs) {
                if pairs.isEmpty {
                    Text("No environment variables configured")
                        .font(KumaFont.caption)
                        .foregroundColor(KumaColor.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, KumaSpacing.xs)
                } else {
                    ForEach(pairs) { pair in
                        pairRow(for: pair)
                    }
                }

                if !isDisabled {
                    Divider()
                        .padding(.vertical, KumaSpacing.xs)
                    addPairControls
                }
            }
            .padding(KumaSpacing.sm)
            .background(KumaColor.surfaceBackground)
            .cornerRadius(KumaRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: KumaRadius.md)
                    .stroke(errorMessage != nil ? KumaColor.errorText : KumaColor.cardBorder, lineWidth: 1)
            )

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(KumaFont.caption)
                    .foregroundColor(KumaColor.errorText)
            } else if let helpText = helpText {
                Text(helpText)
                    .font(KumaFont.caption)
                    .foregroundColor(KumaColor.textSecondary)
            }
        }
    }

    @ViewBuilder
    private func pairRow(for pair: KumaKeyValuePair) -> some View {
        HStack(spacing: KumaSpacing.xs) {
            Text(pair.key)
                .font(KumaFont.code)
                .fontWeight(.medium)
                .foregroundColor(KumaColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("=")
                .font(KumaFont.code)
                .foregroundColor(KumaColor.textSecondary)

            Text(pair.value)
                .font(KumaFont.code)
                .foregroundColor(KumaColor.textSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !isDisabled {
                Button(action: { removePair(id: pair.id) }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(KumaColor.errorText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove key \(pair.key)")
            }
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var addPairControls: some View {
        HStack(spacing: KumaSpacing.xs) {
            TextField(keyPlaceholder, text: $newKey)
                .textFieldStyle(.plain)
                .font(KumaFont.caption)
                .padding(KumaSpacing.xs)
                .background(KumaColor.surfaceBackground)
                .cornerRadius(KumaRadius.sm)

            TextField(valuePlaceholder, text: $newValue)
                .textFieldStyle(.plain)
                .font(KumaFont.caption)
                .padding(KumaSpacing.xs)
                .background(KumaColor.surfaceBackground)
                .cornerRadius(KumaRadius.sm)

            Button(action: addPair) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(canAdd ? KumaColor.accent : KumaColor.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(!canAdd)
            .accessibilityLabel("Add Key Value Pair")
        }
    }

    private var canAdd: Bool {
        !newKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addPair() {
        let key = newKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return }
        pairs.append(KumaKeyValuePair(key: key, value: newValue))
        newKey = ""
        newValue = ""
    }

    private func removePair(id: UUID) {
        pairs.removeAll(where: { $0.id == id })
    }
}

#Preview {
    KumaKeyValueEditor(
        pairs: .constant([
            KumaKeyValuePair(key: "PORT", value: "8080"),
            KumaKeyValuePair(key: "STAGE", value: "production")
        ])
    )
    .padding()
    .frame(width: 450)
}
