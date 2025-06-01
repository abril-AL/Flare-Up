import SwiftUI
import Supabase

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isAuthenticated = false
    @AppStorage("userId") private var userId: String = ""
    
    var body: some View {
        if isAuthenticated {
            ScreenTimeInputView()
        } else {
            VStack(spacing: 20) {
                Text("Welcome to Flare Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: {
                    Task {
                        await handleSignIn()
                    }
                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button("Don’t have an account? Sign Up") {
                    // Navigate to signup if needed
                }
                .foregroundColor(.blue)
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func handleSignIn() async {
        do {
            try await SupabaseManager.shared.signIn(email: email, password: password)
            let session = try await SupabaseManager.shared.getSession()
            self.userId = session.user.id.uuidString

            self.isAuthenticated = true
        } catch {
            self.alertMessage = error.localizedDescription
            self.showAlert = true
        }
    }
}



