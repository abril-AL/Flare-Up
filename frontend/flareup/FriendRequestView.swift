import SwiftUI


struct FriendRequestsView: View {
    @EnvironmentObject var session: SessionViewModel

    var body: some View {
        VStack(spacing: 0) {
            FlareupHeader {}

            // Title row
            HStack {
                Button(action: {
                    // dismiss or pop navigation
                }) { /* Back button (optional) */ }

                Text("friend requests")
                    .font(.custom("Poppins-Bold", size: 30))
                    .foregroundColor(Color(hex: "F7941D"))

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)

            // Requests List
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(session.incomingRequests) { request in
                        HStack(alignment: .center, spacing: 16) {
                            Image(request.imageName)
                                .resizable()
                                .frame(width: 65, height: 65)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(request.name.capitalized)
                                    .font(.custom("Poppins-Bold", size: 20))
                                    .foregroundColor(Color(hex: "F25D29"))

                                Text("@\(request.username)")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Button(action: {
                                Task {
                                    await respondToRequest(senderId: request.sender_id, accept: true)
                                }
                            }) {
                                Text("approve")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "F25D29"))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .shadow(radius: 2)
                            }

                            Button(action: {
                                Task {
                                    await respondToRequest(senderId: request.sender_id, accept: false)
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color(hex: "F25D29"))
                            }
                        }
                        .padding()
                        .background(Color(hex: "FFF5E9"))
                        .cornerRadius(40)
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 10)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .task {
            await session.loadFriendRequests()
        }
    }

    private func respondToRequest(senderId: String, accept: Bool) async {
        guard !session.userId.isEmpty else { return }

        let endpoint = accept ? "accept" : "decline"
        guard let url = URL(string: "http://localhost:4000/friends/\(endpoint)") else {
            print("❌ Invalid \(endpoint) URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: String] = [
            "sender_id": senderId,
            "receiver_id": session.userId
        ]

        do {
            request.httpBody = try JSONEncoder().encode(payload)
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ Friend request \(accept ? "accepted" : "declined")")
                await session.loadFriendRequests()
                await session.fetchFriends(for: session.userId)
            } else {
                print("❌ Server error handling friend request")
            }
        } catch {
            print("❌ Error responding to friend request:", error.localizedDescription)
        }
    }
}

