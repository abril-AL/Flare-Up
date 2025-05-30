import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var confirmPassword = ""
    
    init(authViewModel: AuthViewModel) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundOrange")
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                HStack {
                    Image("ThinkingLogo")
                        .resizable()
                        .frame(width: 326, height: 103.67)
                    Spacer()
                }
                .padding(.horizontal)
                
                VStack(spacing: 20) {
                    Text("Sign Up")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentRed"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 28)
                    
                    // Username field
                    HStack(spacing: 12) {
                        Image("LogInPerson")
                            .renderingMode(.template)
                            .foregroundColor(.gray)
                        
                        TextField("Username", text: $username)
                            .font(.custom("Poppins-Regular", size: 15))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                    }
                    .padding(.leading, 16)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: .black.opacity(0.1), radius: 2.65, x: -1, y: 2.5)
                    .padding(.horizontal, 28)
                    
                    // Email field
                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        
                        TextField("Email", text: $email)
                            .font(.custom("Poppins-Regular", size: 15))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding(.leading, 16)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: .black.opacity(0.1), radius: 2.65, x: -1, y: 2.5)
                    .padding(.horizontal, 28)
                    
                    // Password field
                    HStack(spacing: 12) {
                        Image("LogInLock")
                            .renderingMode(.template)
                            .foregroundColor(.gray)
                        
                        SecureField("Password", text: $password)
                            .font(.custom("Poppins-Regular", size: 15))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                    }
                    .padding(.leading, 16)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: .black.opacity(0.1), radius: 2.65, x: -1, y: 2.5)
                    .padding(.horizontal, 28)
                    
                    // Confirm Password field
                    HStack(spacing: 12) {
                        Image("LogInLock")
                            .renderingMode(.template)
                            .foregroundColor(.gray)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .font(.custom("Poppins-Regular", size: 15))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                    }
                    .padding(.leading, 16)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: .black.opacity(0.1), radius: 2.65, x: -1, y: 2.5)
                    .padding(.horizontal, 28)
                    
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, 28)
                    }
                    
                    // Sign Up button
                    Button {
                        if password == confirmPassword {
                            authViewModel.signUp(email: email, password: password, username: username)
                        }
                    } label: {
                        Text("Sign Up")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("AccentRed"))
                            .cornerRadius(28)
                    }
                    .disabled(password != confirmPassword || username.isEmpty || email.isEmpty || password.isEmpty)
                    .opacity(password != confirmPassword || username.isEmpty || email.isEmpty || password.isEmpty ? 0.6 : 1)
                    .padding(.horizontal, 28)
                    
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.gray)
                        Button("Login") {
                            dismiss()
                        }
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentRed"))
                    }
                    .padding(.bottom, 90)
                    .padding(.top, 12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("LightComponent"))
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .ignoresSafeArea(edges: .bottom)
            }
            .padding(.top, 26)
        }
    }
} 