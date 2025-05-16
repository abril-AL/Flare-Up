//
//  flareupApp.swift
//  flareup
//
//  Created by Richelle Shim on 5/9/25.
//


import SwiftUI

@main
struct FlareupApp: App {
    // 1. A @State flag to know when to hide the splash
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            // 2. Conditionally show either SplashView or your real ContentView
            if showSplash {
                SplashView(isActive: $showSplash)
            } else {
                LoginView()
            }
        }
    }
}
