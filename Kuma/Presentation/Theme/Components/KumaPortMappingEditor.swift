//
//  KumaPortMappingEditor.swift
//  Kuma
//

import SwiftUI

/// FormKit editor component for managing local-to-remote port forwarding mappings.
@MainActor
public struct KumaPortMappingEditor: View {
    let title: String?
    @Binding var mappings: [PortMapping]
    let providerId: UUID
    let helpText: String?
    let errorMessage: String?
    let isDisabled: Bool

    @State private var newLocalPortString: String = ""
    @State private var newRemotePortString: String = ""
    @State private var newProtocolType: String = "tcp"

    @State private var copiedPort: Int?

    public init(
        title: String? = "Port Mappings",
        mappings: Binding<[PortMapping]>,
        providerId: UUID,
        helpText: String? = nil,
        errorMessage: String? = nil,
        isDisabled: Bool = false
    ) {
        self.title = title
        self._mappings = mappings
        self.providerId = providerId
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
                if mappings.isEmpty {
                    Text("No port mappings configured")
                        .font(KumaFont.caption)
                        .foregroundColor(KumaColor.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, KumaSpacing.xs)
                } else {
                    ForEach(mappings) { mapping in
                        portRow(for: mapping)
                    }
                }

                if !isDisabled {
                    Divider()
                        .padding(.vertical, KumaSpacing.xs)
                    addMappingControls
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
    private func portRow(for mapping: PortMapping) -> some View {
        HStack(spacing: KumaSpacing.sm) {
            Button(action: { copyPortURL(mapping.localPort) }) {
                HStack(spacing: 4) {
                    Text("http://localhost:\(mapping.localPort)")
                        .font(KumaFont.code)
                        .foregroundColor(KumaColor.textPrimary)

                    Image(systemName: copiedPort == mapping.localPort ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 9))
                        .foregroundColor(copiedPort == mapping.localPort ? KumaColor.statusRunning : KumaColor.textSecondary)
                }
                .padding(.horizontal, KumaSpacing.xs)
                .padding(.vertical, 2)
                .background(KumaColor.cardBorder)
                .cornerRadius(KumaRadius.sm)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Copy URL http://localhost:\(mapping.localPort)")

            Image(systemName: "arrow.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(KumaColor.textSecondary)

            Text("\(mapping.remotePort)")
                .font(KumaFont.code)
                .foregroundColor(KumaColor.textPrimary)
                .frame(width: 50, alignment: .leading)

            Text(mapping.protocolType.uppercased())
                .font(KumaFont.caption)
                .fontWeight(.semibold)
                .foregroundColor(KumaColor.accent)
                .padding(.horizontal, KumaSpacing.xs)
                .padding(.vertical, 2)
                .background(KumaColor.accent.opacity(0.15))
                .cornerRadius(KumaRadius.sm)

            Spacer()

            if !isDisabled {
                Button(action: { removeMapping(id: mapping.id) }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(KumaColor.errorText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove port mapping \(mapping.localPort) to \(mapping.remotePort)")
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var addMappingControls: some View {
        HStack(spacing: KumaSpacing.xs) {
            TextField("Local (e.g. 8080)", text: $newLocalPortString)
                .textFieldStyle(.plain)
                .font(KumaFont.caption)
                .padding(KumaSpacing.xs)
                .background(KumaColor.surfaceBackground)
                .cornerRadius(KumaRadius.sm)

            TextField("Remote (e.g. 80)", text: $newRemotePortString)
                .textFieldStyle(.plain)
                .font(KumaFont.caption)
                .padding(KumaSpacing.xs)
                .background(KumaColor.surfaceBackground)
                .cornerRadius(KumaRadius.sm)

            Picker("", selection: $newProtocolType) {
                Text("TCP").tag("tcp")
                Text("UDP").tag("udp")
            }
            .pickerStyle(.segmented)
            .frame(width: 90)

            Button(action: addMapping) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(canAdd ? KumaColor.accent : KumaColor.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(!canAdd)
            .accessibilityLabel("Add Port Mapping")
        }
    }

    private var canAdd: Bool {
        guard let local = Int(newLocalPortString), local > 0 && local <= 65535,
              let remote = Int(newRemotePortString), remote > 0 && remote <= 65535,
              !mappings.contains(where: { $0.localPort == local }) else {
            return false
        }
        return true
    }

    private func addMapping() {
        guard let local = Int(newLocalPortString), let remote = Int(newRemotePortString),
              !mappings.contains(where: { $0.localPort == local }) else { return }
        let newMapping = PortMapping(
            providerId: providerId,
            localPort: local,
            remotePort: remote,
            protocolType: newProtocolType
        )
        mappings.append(newMapping)
        newLocalPortString = ""
        newRemotePortString = ""
    }

    private func copyPortURL(_ port: Int) {
        let urlString = "http://localhost:\(port)"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(urlString, forType: .string)
        copiedPort = port
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if copiedPort == port {
                copiedPort = nil
            }
        }
    }

    private func removeMapping(id: UUID) {
        mappings.removeAll(where: { $0.id == id })
    }
}

#Preview {
    KumaPortMappingEditor(
        mappings: .constant([
            PortMapping(providerId: UUID(), localPort: 8080, remotePort: 80, protocolType: "tcp"),
            PortMapping(providerId: UUID(), localPort: 5432, remotePort: 5432, protocolType: "tcp")
        ]),
        providerId: UUID()
    )
    .padding()
    .frame(width: 450)
}
