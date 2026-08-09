//
//  ServiceAggregate.swift
//  Kuma
//
//  Created for Task 6.3 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import Foundation

/// Pure domain root aggregate encapsulating a Service and all its associated entities,
/// active provider selections, port mappings, secrets, and execution state.
/// Eliminates multi-dictionary state desync bugs in Presentation & Stores layers.
public struct ServiceAggregate: Identifiable, Sendable, Equatable, Hashable {
    public var service: Service
    public var providers: [Provider]
    public var activeProvider: Provider?
    public var portMappings: [PortMapping]
    public var vaultSecrets: [VaultSecret]
    public var state: ServiceExecutionState

    public var id: UUID {
        service.id
    }

    public var name: String {
        service.name
    }

    public var workspaceId: UUID {
        service.workspaceId
    }

    public var groupId: UUID? {
        service.groupId
    }

    public var isFavorite: Bool {
        service.isFavorite
    }

    public var isDisabled: Bool {
        service.isDisabled
    }

    public nonisolated init(
        service: Service,
        providers: [Provider] = [],
        activeProvider: Provider? = nil,
        portMappings: [PortMapping] = [],
        vaultSecrets: [VaultSecret] = [],
        state: ServiceExecutionState = .stopped
    ) {
        self.service = service
        self.providers = providers
        self.activeProvider = activeProvider ?? providers.first(where: { $0.id == service.activeProviderId }) ?? providers.first
        self.portMappings = portMappings
        self.vaultSecrets = vaultSecrets
        self.state = state
    }
}
