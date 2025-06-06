//
//  RootView.swift
//  flareup
//
//  Created by Richelle Shim on 5/31/25.
//


//
//  RootView.swift
//  flareup
//
//  Created by Dalton Silverman on 5/31/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: SessionViewModel

    var body: some View {
        Group {
            if session.isAuthenticated {
                MainView()
            } else {
                LoginView()
            }
        }
    }
}
