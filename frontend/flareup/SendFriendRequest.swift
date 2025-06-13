import SwiftUI



struct SendFriendRequestView: View {
    @State private var username: String = ""
    @EnvironmentObject var session: SessionViewModel
    @State private var showSuccessAlert = false
    @State private var successMessage = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    func sendFriendRequest(from senderId: String) async {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else {
            print("⚠️ Username is empty")
            await MainActor.run {
                errorMessage = "Please enter a username."
                showErrorAlert = true
            }
            return
        }

        do {
            print("🔍 Looking up user with username: \(trimmedUsername)")

            // 1. Lookup receiver_id from username
            guard let lookupURL = URL(string: "http://localhost:4000/users/lookup/\(trimmedUsername)") else {
                print("❌ Invalid lookup URL")
                return
            }

            let (lookupData, lookupResponse) = try await URLSession.shared.data(from: lookupURL)

            // Debug raw response
            if let rawJSON = String(data: lookupData, encoding: .utf8) {
                print("📄 Raw lookup response:\n\(rawJSON)")
            }

            // Check if status is 404 (user not found)
            if let httpResponse = lookupResponse as? HTTPURLResponse, httpResponse.statusCode == 404 {
                print("❌ User '@\(trimmedUsername)' not found.")
                await MainActor.run {
                    errorMessage = "User '@\(trimmedUsername)' not found."
                    showErrorAlert = true
                }
                return
            }

            // Decode user ID from lookup
            struct UserIDResponse: Decodable {
                let id: String
            }

            let decoded = try JSONDecoder().decode(UserIDResponse.self, from: lookupData)
            let receiverId = decoded.id

            print("📬 Preparing to send friend request from \(senderId) → \(receiverId)")

            // 2. Send the friend request
            guard let requestURL = URL(string: "http://localhost:4000/friends/request") else {
                print("❌ Invalid request URL")
                return
            }

            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: String] = [
                "sender_id": senderId,
                "receiver_id": receiverId
            ]

            request.httpBody = try JSONEncoder().encode(body)

            let (responseData, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("📨 HTTP Status: \(httpResponse.statusCode)")

                switch httpResponse.statusCode {
                case 200:
                    print("✅ Friend request successfully sent to \(receiverId)")
                    await MainActor.run {
                        successMessage = "Friend request sent to @\(trimmedUsername)"
                        showSuccessAlert = true
                        username = ""
                    }

                case 409:
                    print("⚠️ Duplicate friend request")
                    await MainActor.run {
                        errorMessage = "You've already sent a friend request to @\(trimmedUsername)."
                        showErrorAlert = true
                    }

                case 400...499:
                    if let errorJSON = String(data: responseData, encoding: .utf8) {
                        print("❌ Client-side error:\n\(errorJSON)")
                        await MainActor.run {
                            errorMessage = "Client error: \(errorJSON)"
                            showErrorAlert = true
                        }
                    } else {
                        await MainActor.run {
                            errorMessage = "Something went wrong. Please check your input."
                            showErrorAlert = true
                        }
                    }

                case 500...599:
                    print("❌ Server error (5xx)")
                    await MainActor.run {
                        errorMessage = "Server error. Please try again later."
                        showErrorAlert = true
                    }

                default:
                    print("❌ Unexpected HTTP status code")
                    await MainActor.run {
                        errorMessage = "Unexpected error. Please try again."
                        showErrorAlert = true
                    }
                }
            }

        } catch {
            print("❌ Unexpected error: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = "Something went wrong. Please try again."
                showErrorAlert = true
            }
        }
    }




    var body: some View {
        ZStack {
            Color(hex: "F7941D").ignoresSafeArea() // Covers entire background including behind header
            VStack(spacing: 0) {
                    // Light orange block at the top (to mimic flareupHeader background)
                    Rectangle()
                        .fill(Color(hex: "FFF2E2"))
                        .frame(height: 150) // adjust height as needed
                        .offset(y:-100)
                    Spacer()
                }
            VStack(spacing: 24) {
                FlareupHeader()

                Text("Add by Username")
                    .font(.custom("Poppins-Bold", size: 35))
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    Text("Who would you like to add as a friend?")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.white)

                    TextField("abrilchuzz", text: $username)
                        .padding()
                        .background(Color(hex: "FFA74F"))
                        .cornerRadius(30)
                        .foregroundColor(.white)
                        .font(.custom("Poppins-Regular", size: 18))
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding(.horizontal)
                }

                Button(action: {
                    Task {
                        let senderId = session.userId
                        await sendFriendRequest(from: senderId)
                    }
                }) {
                    Text("send friend request")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(Color(hex: "F7941D"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(30)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 32)
        }
        .alert(isPresented: $showSuccessAlert) {
                Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
    }
}
#Preview {
    SendFriendRequestView()
}
