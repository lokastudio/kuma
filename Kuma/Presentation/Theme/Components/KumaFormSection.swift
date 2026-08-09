//
//  KumaFormSection.swift
//  Kuma
//

import SwiftUI

/// Primary container component for form inputs with header, description, contained box, and optional footer/validation error note.
@MainActor
public struct KumaFormSection<Content: View, HeaderAction: View>: View {
    private let title: String?
    private let description: String?
    private let footer: String?
    private let errorMessage: String?
    private let headerAction: HeaderAction?
    private let content: Content

    public init(
        title: String? = nil,
        description: String? = nil,
        footer: String? = nil,
        errorMessage: String? = nil,
        @ViewBuilder headerAction: () -> HeaderAction,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.footer = footer
        self.errorMessage = errorMessage
        self.headerAction = headerAction()
        self.content = content()
    }

    public init(
        title: String? = nil,
        description: String? = nil,
        footer: String? = nil,
        errorMessage: String? = nil,
        @ViewBuilder content: () -> Content
    ) where HeaderAction == EmptyView {
        self.title = title
        self.description = description
        self.footer = footer
        self.errorMessage = errorMessage
        self.headerAction = nil
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: KumaSpacing.xs) {
            if let title {
                KumaSectionHeader(title: title, subtitle: description) {
                    if let headerAction {
                        headerAction
                    }
                }
            }

            KumaCardContainer(padding: KumaSpacing.md, isInteractive: false) {
                VStack(alignment: .leading, spacing: KumaSpacing.sm) {
                    content
                }
            }

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(KumaFont.caption)
                    .foregroundColor(KumaColor.statusError)
                    .accessibilityLabel("Validation error: \(errorMessage)")
            } else if let footer, !footer.isEmpty {
                Text(footer)
                    .font(KumaFont.caption)
                    .foregroundColor(KumaColor.textMuted)
            }
        }
    }
}

#Preview {
    VStack(spacing: KumaSpacing.xl) {
        KumaFormSection(
            title: "Database Connection",
            description: "Configure local PostgreSQL tunnel options.",
            footer: "Ensure the local port is not used by another service."
        ) {
            Text("Form Input Field Placeholder")
                .font(KumaFont.body)
                .foregroundColor(KumaColor.textSecondary)
        }

        KumaFormSection(
            title: "Authentication Token",
            errorMessage: "Token has expired or is invalid."
        ) {
            Text("Secure Input Field Placeholder")
                .font(KumaFont.body)
                .foregroundColor(KumaColor.textSecondary)
        }
    }
    .padding()
    .frame(width: 450)
    .background(KumaColor.surfaceBackground)
}
