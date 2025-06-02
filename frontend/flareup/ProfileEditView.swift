import SwiftUI

struct ProfileEditView: View {
    @Binding var isEditing: Bool
    @Binding var name: String
    @Binding var username: String
    @Binding var statusMessage: String
    @Binding var screentimeGoal: String

    @Environment(\.presentationMode) var presentationMode
    @State private var showingSignOutAlert = false
    @State private var isSigningOut = false
    @EnvironmentObject var session: SessionViewModel
    @AppStorage("authToken") private var authToken: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Name", text: $name)
                        .font(.custom("Poppins-Regular", size: 16))
                    TextField("Username", text: $username)
                        .font(.custom("Poppins-Regular", size: 16))
                    TextField("Status Message", text: $statusMessage)
                        .font(.custom("Poppins-Regular", size: 16))
                    TextField("Screen Time Goal", text: $screentimeGoal)
                        .font(.custom("Poppins-Regular", size: 16))
                }

                Section {
                    Button(action: {
                        showingSignOutAlert = true
                    }) {
                        HStack {
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isEditing = false
                },
                trailing: Button("Save") {
                    Task {
                        await updateUserProfile()
                        isEditing = false
                    }
                }
            )
            .alert(isPresented: $showingSignOutAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) {
                        signOut()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func updateUserProfile() async {
        guard let url = URL(string: "\(Config.backendURL)/users/update") else {
            print("Invalid URL")
            return
        }

        let goalMinutes = Int(screentimeGoal.filter("0123456789".contains)) ?? 0

        let payload: [String: Any] = [
            "username": username,
            "goal_screen_time": goalMinutes
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("Server responded with status:", httpResponse.statusCode)
            }

            if let body = String(data: data, encoding: .utf8) {
                print("Server response body:", body)
            }
        } catch {
            print("Error updating profile:", error.localizedDescription)
        }
    }

    private func signOut() {
        isSigningOut = true
        Task {
            await session.signOut()
            isSigningOut = false
        }
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView(
            isEditing: .constant(true),
            name: .constant("scotty"),
            username: .constant("squatpawk"),
            statusMessage: .constant("locked in"),
            screentimeGoal: .constant("3 Hours")
        )
        .environmentObject(SessionViewModel()) // needed for preview
    }
}
