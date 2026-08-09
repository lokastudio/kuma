//
//  KubeConfigRepositoryProtocol.swift
//  Kuma
//
//  Created for Task 3.5 in accordance with AGENTS.md, ERD.md & ROADMAP.md.
//

import Foundation

/// Protocol defining async persistence operations for `KubeConfig` domain entities.
public protocol KubeConfigRepositoryProtocol: Sendable {
    /// Fetch all registered KubeConfig references.
    func fetchKubeConfigs() async throws -> [KubeConfig]

    /// Fetch a single KubeConfig by its unique identifier.
    func fetchKubeConfig(id: UUID) async throws -> KubeConfig?

    /// Save or update a KubeConfig reference.
    func saveKubeConfig(_ kubeConfig: KubeConfig) async throws

    /// Delete a KubeConfig reference by its unique identifier.
    func deleteKubeConfig(id: UUID) async throws

    /// Set a specific KubeConfig as the default context configuration.
    func setDefaultKubeConfig(id: UUID) async throws
}
