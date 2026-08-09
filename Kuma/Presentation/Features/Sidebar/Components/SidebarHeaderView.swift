//
//  SidebarHeaderView.swift
//  Kuma
//
//  Created for Task 7.4 in accordance with AGENTS.md, UX_SPECIFICATION.md & ROADMAP.md.
//

import SwiftUI

/// Workspace selector dropdown header in Kuma Sidebar.
public struct SidebarHeaderView: View {
    @Environment(WorkspaceStore.self) private var workspaceStore
    @Environment(ServiceStore.self) private var serviceStore

    public init() {}

    public var body: some View {
        HStack(spacing: KumaSpacing.xs) {
            // Workspace Icon / Avatar
            if let avatar = workspaceStore.avatarImage(for: workspaceStore.activeWorkspace?.imagePath, maxDimension: 32) {
                Image(nsImage: avatar)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 22, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: KumaRadius.sm))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: KumaRadius.sm)
                        .fill(KumaTheme.Color.accent.opacity(0.15))
                        .frame(width: 22, height: 22)

                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(KumaTheme.Color.accent)
                }
            }

            // Workspace Picker Dropdown Menu
            Menu {
                Section("Workspaces") {
                    ForEach(workspaceStore.workspaces) { workspace in
                        Button {
                            selectWorkspace(workspace)
                        } label: {
                            HStack {
                                Text(workspace.name)
                                if workspace.id == workspaceStore.activeWorkspaceId {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(workspaceStore.activeWorkspace?.name ?? "Workspace")
                        .font(KumaTheme.Font.headline)
                        .foregroundStyle(KumaTheme.Color.textPrimary)
                        .lineLimit(1)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(KumaTheme.Color.textMuted)
                }
            }
            .menuStyle(.borderlessButton)
            .fixedSize()

            Spacer()
        }
        .padding(.horizontal, KumaSpacing.sm)
        .padding(.vertical, KumaSpacing.xs)
    }

    private func selectWorkspace(_ workspace: Workspace) {
        let hasRunning = serviceStore.hasRunningServices
        workspaceStore.selectWorkspace(id: workspace.id, hasActiveServices: hasRunning)
    }
}

#Preview("SidebarHeaderView") {
    SidebarHeaderView()
        .environment(WorkspaceStore.mock)
        .environment(ServiceStore.mock)
        .frame(width: 240)
}
