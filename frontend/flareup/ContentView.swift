import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                }

            FocusView()
                .tabItem {
                    Image(systemName: "star")
                }

            StatsView()
                .tabItem {
                    Image(systemName: "person.2")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                }
        }
        .accentColor(.orange) // Highlight color for selected tab
    }
}

#Preview {
    ContentView()
}

