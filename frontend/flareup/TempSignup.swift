import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var username = ""
    @State private var screentimeGoal = ""
    @State private var showAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)

            Group {
                TextField("Name", text: $name)
                TextField("Username", text: $username)
                TextField("Daily Screentime Goal (e.g., 3 for 3 hours)", text: $screentimeGoal)
                    .keyboardType(.numberPad)
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)

            Button(action: {
                Task {
                    await handleSignUp()
                }
            }) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Button("Already have an account? Sign In") {
                // Hook up navigation
            }
            .foregroundColor(.blue)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(session.errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func handleSignUp() async {
        do {
            try await session.signUp(email: email, password: password)
            try await postUserProfile()
        } catch {
            showAlert = true
        }
    }

    private func postUserProfile() async throws {
        guard let url = URL(string: "\(Config.backendURL)/users/init") else {
            print("❌ Invalid backend URL")
            return
        }

        guard let goalMinutes = Int(screentimeGoal) else {
            print("❌ Invalid screentime goal format")
            return
        }

        let payload: [String: Any] = [
            "name": name,
            "username": username,
            "goal_screen_time": goalMinutes
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(session.authToken)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ User profile init response:", httpResponse.statusCode)
            }

            if let body = String(data: data, encoding: .utf8) {
                print("✅ Server response:", body)
            }
        } catch {
            print("❌ Failed to send user metadata:", error.localizedDescription)
            throw error
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(SessionViewModel())
    }
}
