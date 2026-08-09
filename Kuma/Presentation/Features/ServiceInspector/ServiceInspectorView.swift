//
//  ServiceInspectorView.swift
//  Kuma
//
//  Created for Task 7.7 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Main Service Inspector panel container view displaying header, provider switcher, port mapping resolver, and log stream viewer.
@MainActor
public struct ServiceInspectorView: View {
    public let aggregate: ServiceAggregate
    public let logs: [String]
    public let onClose: () -> Void
    public let onToggleExecution: () -> Void
    public let onSelectProvider: (Provider) -> Void
    public let onFreePortRequested: (PortMapping) -> Void
    public let onClearLogs: () -> Void

    public init(
        aggregate: ServiceAggregate,
        logs: [String],
        onClose: @escaping () -> Void,
        onToggleExecution: @escaping () -> Void,
        onSelectProvider: @escaping (Provider) -> Void,
        onFreePortRequested: @escaping (PortMapping) -> Void,
        onClearLogs: @escaping () -> Void
    ) {
        self.aggregate = aggregate
        self.logs = logs
        self.onClose = onClose
        self.onToggleExecution = onToggleExecution
        self.onSelectProvider = onSelectProvider
        self.onFreePortRequested = onFreePortRequested
        self.onClearLogs = onClearLogs
    }

    public var body: some View {
        VStack(spacing: 0) {
            InspectorHeaderView(
                title: aggregate.name,
                state: aggregate.state,
                onToggleExecution: onToggleExecution,
                onClose: onClose
            )

            Divider()
                .background(KumaTheme.Color.cardBorder)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: KumaSpacing.md) {
                    InspectorProviderSelectorView(
                        providers: aggregate.providers,
                        activeProvider: aggregate.activeProvider,
                        onSelectProvider: onSelectProvider
                    )

                    InspectorPortResolverView(
                        portMappings: aggregate.portMappings,
                        onFreePortRequested: onFreePortRequested
                    )

                    InspectorLogStreamView(
                        logs: logs,
                        onClearLogs: onClearLogs
                    )
                }
                .padding(.vertical, KumaSpacing.md)
            }
        }
        .frame(minWidth: 320, idealWidth: 360)
        .background(KumaTheme.Color.windowBackground)
    }
}

#Preview {
    let serviceId = UUID()
    let providerId = UUID()
    ServiceInspectorView(
        aggregate: ServiceAggregate(
            service: Service(
                id: serviceId,
                workspaceId: UUID(),
                name: "PostgreSQL Database",
                description: "Development Postgres instance",
                isFavorite: true,
                activeProviderId: providerId,
                createdAt: Date(),
                updatedAt: Date()
            ),
            providers: [
                Provider(
                    id: providerId,
                    serviceId: serviceId,
                    config: .dockerCompose(DockerComposePayload(projectDirectory: "~", composeFilePath: "~/docker-compose.yml", serviceName: "postgres")),
                    createdAt: Date(),
                    updatedAt: Date()
                )
            ],
            activeProvider: Provider(
                id: providerId,
                serviceId: serviceId,
                config: .dockerCompose(DockerComposePayload(projectDirectory: "~", composeFilePath: "~/docker-compose.yml", serviceName: "postgres")),
                createdAt: Date(),
                updatedAt: Date()
            ),
            portMappings: [
                PortMapping(id: UUID(), providerId: providerId, localPort: 5432, remotePort: 5432, protocolType: "tcp")
            ],
            vaultSecrets: [],
            state: .running(pid: 1234, activePort: 5432)
        ),
        logs: [
            "[2026-08-09 12:00:00] Starting PostgreSQL server...",
            "[2026-08-09 12:00:01] Database system is ready to accept connections."
        ],
        onClose: {},
        onToggleExecution: {},
        onSelectProvider: { _ in },
        onFreePortRequested: { _ in },
        onClearLogs: {}
    )
}
