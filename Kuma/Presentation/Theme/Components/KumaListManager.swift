//
//  KumaListManager.swift
//  Kuma
//

import SwiftUI

/// FormKit manager component for managing arbitrary lists of strings (e.g., CLI flags, arguments, tags).
@MainActor
public struct KumaListManager: View {
    let title: String?
    @Binding var items: [String]
    let placeholder: String
    let helpText: String?
    let errorMessage: String?
    let isDisabled: Bool

    @State private var newItem: String = ""

    public init(
        title: String? = "Arguments & Flags",
        items: Binding<[String]>,
        placeholder: String = "Add item (e.g. --verbose)",
        helpText: String? = nil,
        errorMessage: String? = nil,
        isDisabled: Bool = false
    ) {
        self.title = title
        self._items = items
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

            VStack(spacing: KumaSpacing.xs) {
                if items.isEmpty {
                    Text("No items added")
                        .font(KumaFont.caption)
                        .foregroundColor(KumaColor.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, KumaSpacing.xs)
                } else {
                    FlowLayout(spacing: KumaSpacing.xs) {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            itemChip(item, at: index)
                        }
                    }
                }

                if !isDisabled {
                    Divider()
                        .padding(.vertical, KumaSpacing.xs)
                    addItemControls
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
    private func itemChip(_ item: String, at index: Int) -> some View {
        HStack(spacing: 4) {
            Text(item)
                .font(KumaFont.caption)
                .foregroundColor(KumaColor.textPrimary)

            if !isDisabled {
                Button(action: { removeItem(at: index) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(KumaColor.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove item \(item)")
            }
        }
        .padding(.horizontal, KumaSpacing.xs)
        .padding(.vertical, 4)
        .background(KumaColor.cardBorder)
        .cornerRadius(KumaRadius.sm)
    }

    @ViewBuilder
    private var addItemControls: some View {
        HStack(spacing: KumaSpacing.xs) {
            TextField(placeholder, text: $newItem, onCommit: addItem)
                .textFieldStyle(.plain)
                .font(KumaFont.caption)
                .padding(KumaSpacing.xs)
                .background(KumaColor.surfaceBackground)
                .cornerRadius(KumaRadius.sm)

            Button(action: addItem) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(canAdd ? KumaColor.accent : KumaColor.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(!canAdd)
            .accessibilityLabel("Add item")
        }
    }

    private var canAdd: Bool {
        !newItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addItem() {
        let trimmed = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.append(trimmed)
        newItem = ""
    }

    private func removeItem(at index: Int) {
        guard index >= 0 && index < items.count else { return }
        items.remove(at: index)
    }
}

/// Helper container layout for wrapping chip items horizontally.
struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxHeightInRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width {
                currentX = 0
                currentY += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            currentX += size.width + spacing
            maxHeightInRow = max(maxHeightInRow, size.height)
        }

        return CGSize(width: width, height: currentY + maxHeightInRow)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var maxHeightInRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            maxHeightInRow = max(maxHeightInRow, size.height)
        }
    }
}

#Preview {
    KumaListManager(
        items: .constant(["--verbose", "--port 8080", "--env stage"])
    )
    .padding()
    .frame(width: 450)
}
