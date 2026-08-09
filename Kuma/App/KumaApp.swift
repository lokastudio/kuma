//
//  KumaApp.swift
//  Kuma
//
//  Created for Kuma V4 Native macOS App.
//  Zero-compromise Swift 6 Strict Concurrency architecture.
//

import SwiftUI

@main
struct KumaApp: App {
    @State private var appStore: AppStore
    @State private var workspaceStore: WorkspaceStore
    @State private var serviceStore: ServiceStore
    @State private var kubeConfigStore: KubeConfigStore

    init() {
        // Enforce single instance activation guard on application launch
        if WindowCoordinator.activateExistingInstanceIfRunning() {
            exit(0)
        }

        let dbManager = (try? DatabaseManager.makeInMemory()) ?? (try! DatabaseManager.makePersistent())
        let workspaceRepo = GRDBWorkspaceRepository(dbWriter: dbManager.dbWriter)
        let serviceRepo = GRDBServiceRepository(dbWriter: dbManager.dbWriter)
        let providerRepo = GRDBProviderRepository(dbManager: dbManager)
        let masterKeyVault = MasterKeyVault(dbManager: dbManager)
        let vaultSecretRepo = GRDBVaultSecretRepository(dbManager: dbManager, masterKeyVault: masterKeyVault)
        let kubeConfigRepo = GRDBKubeConfigRepository(dbManager: dbManager)

        _appStore = State(wrappedValue: AppStore(initialPhase: .splash))
        _workspaceStore = State(wrappedValue: WorkspaceStore(repository: workspaceRepo))
        _serviceStore = State(wrappedValue: ServiceStore(
            serviceRepository: serviceRepo,
            providerRepository: providerRepo,
            vaultSecretRepository: vaultSecretRepo
        ))
        _kubeConfigStore = State(wrappedValue: KubeConfigStore(repository: kubeConfigRepo))
    }

    var body: some Scene {
        WindowGroup {
            WindowCoordinatorView()
                .environment(appStore)
                .environment(workspaceStore)
                .environment(serviceStore)
                .environment(kubeConfigStore)
                .modifier(WindowBackgroundModifier())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

private struct WindowBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 15.0, *) {
            content
                .containerBackground(.thinMaterial, for: .window)
        } else {
            content
                .background(.thinMaterial)
        }
    }
}

