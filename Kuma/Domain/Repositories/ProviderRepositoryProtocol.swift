//
//  ProviderRepositoryProtocol.swift
//  Kuma
//
//  Created for Task 3.5 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Protocol defining async persistence operations for `Provider` domain entities and associated port mappings.
public protocol ProviderRepositoryProtocol: Sendable {
    /// Fetch all providers associated with a specific Service ID.
    func fetchProviders(forServiceId serviceId: UUID) async throws -> [Provider]

    /// Fetch a single provider by its unique identifier.
    func fetchProvider(id: UUID) async throws -> Provider?

    /// Save or update a provider configuration.
    func saveProvider(_ provider: Provider) async throws

    /// Delete a provider configuration by its unique identifier.
    func deleteProvider(id: UUID) async throws

    /// Fetch port mappings for a specific Provider ID.
    func fetchPortMappings(forProviderId providerId: UUID) async throws -> [PortMapping]

    /// Save (replace/update) port mappings associated with a specific Provider ID.
    func savePortMappings(_ mappings: [PortMapping], forProviderId providerId: UUID) async throws
}
