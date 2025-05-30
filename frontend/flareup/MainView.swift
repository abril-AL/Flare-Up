import SwiftUI

enum Tab {
    case home, focus, stats, profile
}

struct MainView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                // Active Page
                Group {
                    switch selectedTab {
                    case .home: HomeView()
                    case .focus: FocusView()
                    case .stats: SocialView()
                    case .profile: ProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                
                // Custom Bottom Nav Bar
                HStack {
                    Spacer()
                    navButton(.home, systemImage: "house")
                    Spacer()
                    navButton(.focus, systemImage: "star")
                    Spacer()
                    navButton(.stats, systemImage: "person.2")
                    Spacer()
                    navButton(.profile, systemImage: "person.crop.circle.fill")
                    Spacer()
                }
                .padding(.vertical,25)
                .padding(.bottom, -30)
            }
        }
    }
        @ViewBuilder
        private func navButton(_ tab: Tab, systemImage: String) -> some View {
            Button(action: { selectedTab = tab }) {
                Image(systemName: systemImage)
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == tab ? .orange : .black)
        }
    }
}
#Preview {
    MainView()
}
