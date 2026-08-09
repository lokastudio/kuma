//
//  SidebarView.swift
//  Kuma
//
//  Created for Task 7.4 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Primary navigation sidebar for Kuma, presenting a smart 4-section split navigation with dynamic active badges.
public struct SidebarView: View {
    @Binding public var selection: SidebarSelection?
    @Environment(WorkspaceStore.self) private var workspaceStore
    @Environment(ServiceStore.self) private var serviceStore

    public init(selection: Binding<SidebarSelection?>) {
        self._selection = selection
    }

    public var body: some View {
        VStack(spacing: 0) {
            SidebarHeaderView()

            List(selection: $selection) {
                SidebarMasterSectionView(selection: $selection)
                SidebarProviderSectionView(selection: $selection)
                SidebarFavoritesSectionView()
            }
            .listStyle(.sidebar)

            SidebarFooterView(selection: $selection)
        }
        .alert(
            "Switch Workspace?",
            isPresented: Binding(
                get: { workspaceStore.isSwitchConfirmationPresented },
                set: { if !$0 { workspaceStore.cancelWorkspaceSwitch() } }
            )
        ) {
            Button("Stop Services & Switch", role: .destructive) {
                Task {
                    await workspaceStore.confirmWorkspaceSwitch {
                        await serviceStore.stopAllServices()
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                workspaceStore.cancelWorkspaceSwitch()
            }
        } message: {
            if let activeWorkspaceName = workspaceStore.activeWorkspace?.name {
                Text("Active services are still running in '\(activeWorkspaceName)'. Would you like to stop all running services in this workspace and switch, or cancel?")
            } else {
                Text("Active services are still running in the active workspace. Would you like to stop all running services and switch, or cancel?")
            }
        }
    }
}

#Preview("SidebarView") {
    SidebarView(selection: .constant(.allServices))
        .environment(WorkspaceStore.mock)
        .environment(ServiceStore.mock)
        .frame(width: 260, height: 600)
}
