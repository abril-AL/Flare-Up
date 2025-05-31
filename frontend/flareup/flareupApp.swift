//
//  flareupApp.swift
//  flareup
//
//  Created by Richelle Shim on 5/9/25.
//


import SwiftUI

@main
struct FlareupApp: App {
    @StateObject private var session = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .task {
                    await session.loadSession()
                }
        }
    }
}

