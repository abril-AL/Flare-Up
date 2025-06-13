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

                            NavigationLink(destination: SendFriendRequestView()) {
                                Text("+ add")
                                    .font(.custom("Poppins-Bold", size: 14))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "F7941D"))
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                        
                        NavigationLink(destination: FriendRequestsView()) {
                            HStack(spacing: 16) {
                                Image("angelPic") // Replace with dynamic image if needed
                                    .resizable()
                                    .frame(width: 54, height: 54)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("friend requests")
                                        .font(.custom("Poppins-Bold", size: 25))
                                        .foregroundColor(Color(hex: "F25D29"))
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(hex: "F7941D"))
                            }
                            .padding()
                            .background(Color(hex: "FFF2E2"))
                            .cornerRadius(40)
                            .padding(.horizontal)
                        }
                        
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

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(friend.name.capitalized)
                                        .font(.custom("Poppins-Bold", size: 26))
                                        .foregroundColor(Color(hex: "F25D29"))

                                    Text("@\(friend.username)")
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Button(action: {
                                    if flaredFriends.contains(friend.name) {
                                        flaredFriends.remove(friend.name)
                                    } else {
                                        flaredFriends.insert(friend.name)
                                    }
                                }) {
                                    Image(flaredFriends.contains(friend.name) ? "flare-dark" : "flare-grey")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .background(Circle().fill(Color.white.opacity(0.7)))
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(Color.white)
                            .cornerRadius(40)
                            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
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
        .environmentObject(SessionViewModel.mock)
}
