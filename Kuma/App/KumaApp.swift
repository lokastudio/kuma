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
    var body: some Scene {
        WindowGroup {
            if #available(macOS 15.0, *) {
                ContentView()
                    .containerBackground(.thinMaterial, for: .window)
            } else {
                ContentView()
                    .background(.thinMaterial)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            
            Text("Kuma V4 Native Engine")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Local-First, In-Process Service & Kubernetes Forwarder Architecture")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .frame(minWidth: 600, minHeight: 400)
    }
}

#Preview {
    ContentView()
}
