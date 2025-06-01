//
//  flareupApp.swift
//  flareup
//
//  Created by Richelle Shim on 5/9/25.
//

import SwiftUI

@main
struct FlareUpApp: App {
    @State private var isActive = false
    @StateObject private var session = SessionViewModel()
    

    var body: some Scene {
        WindowGroup {
            Group {
                if isActive {
                    RootView()
                        .environmentObject(session)
                } else {
                    SplashView(isActive: $isActive)
                }
            }
            .task {
                await session.loadSession()
            }
        }
    }
}
