import SwiftUI

struct AllFriendsView: View {
    @State private var flaredFriends: Set<String> = [] // track which friends have been flared
    @EnvironmentObject var session: SessionViewModel

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "FFF2E2").ignoresSafeArea()

            VStack(spacing: 0) {
                FlareupHeader {}

                ScrollView {
                    VStack(spacing: 24) {
                        // Header row
                        HStack {
                            Text("friends")
                                .font(.custom("Poppins-Bold", size: 32))
                                .foregroundColor(Color(hex: "F7941D"))

                            Spacer()

                            Button(action: {
                                let allNames = session.friends.map { $0.name }
                                flaredFriends = Set(allNames.filter { $0 != "scotty" })
                            }) {
                                Text("Flare All")
                                    .font(.custom("Poppins-Regular", size: 14))
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "F25D29"))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                                    .shadow(radius: 3)
                            }
                        }
                        .padding(.horizontal)

                        // Friend list
                        ForEach(
                            session.friends
                                .filter { $0.name != "scotty" }
                                .sorted { $0.name.lowercased() < $1.name.lowercased() },
                            id: \.id
                        ) { friend in
                            HStack(spacing: 16) {
                                Image(friend.imageName)
                                    .resizable()
                                    .frame(width: 85, height: 85)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color(hex: "F7941D"), lineWidth: 3))

                                Text("  " + friend.name.capitalized)
                                    .font(.custom("Poppins-Bold", size: 30))
                                    .foregroundColor(Color(hex: "F25D29"))

                                Spacer()

                                Button(action: {
                                    if flaredFriends.contains(friend.name) {
                                        flaredFriends.remove(friend.name)
                                    } else {
                                        flaredFriends.insert(friend.name)
                                    }
                                }) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.white)
                                        .background(
                                            Circle()
                                                .fill(flaredFriends.contains(friend.name) ? Color.orange : Color(hex: "F7941D"))
                                        )
                                        .shadow(color: flaredFriends.contains(friend.name) ? Color.orange.opacity(0.4) : .clear, radius: 6)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(Color(hex: "FFF5E9"))
                            .cornerRadius(40)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 16)
                }
                .background(Color.white)
            }
        }
    }
}
#Preview {
    AllFriendsView()
    //MainView()
}
