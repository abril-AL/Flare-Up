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
    @StateObject var flareStore = FlareStore()


    var body: some Scene {
        WindowGroup {
            Group {
                if isActive {
                    RootView()
                        .environmentObject(session)
                        .environmentObject(flareStore)
                } else {
                    SplashView(isActive: $isActive)
                }
            }
            .task {
                await session.loadSession()
                //await session.loadUserProfile()
            }
        }
    }
}
