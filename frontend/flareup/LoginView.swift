import SwiftUI

struct LoginView: View {
    @StateObject private var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    
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
                    Text("Login")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentRed"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 28)

                    HStack(spacing: 12) {
                        Image("LogInPerson")
                            .renderingMode(.template)
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

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, 28)
                    }

                    // Login button
                    Button {
                        authViewModel.signIn(email: email, password: password)
                    } label: {
                        Text("Login")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("AccentRed"))
                            .cornerRadius(28)
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                    .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1)
                    .padding(.horizontal, 28)

                    HStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 112, height: 1)
                            .background(Color(red: 0.79, green: 0.79, blue: 0.79))

                        Text("or login with")
                            .font(Font.custom("Poppins", size: 13).weight(.light))
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color(red: 0.54, green: 0.55, blue: 0.57))

                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 112, height: 1)
                            .background(Color(red: 0.79, green: 0.79, blue: 0.79))
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 30)

                    Button {
                        // Apple Sign In (implement if needed)
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: 68, height: 56)
                            .shadow(color: .black.opacity(0.1), radius: 2.65, x: -1, y: 2.5)
                            .overlay {
                                Image(systemName: "apple.logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30.12, height: 37)
                                    .opacity(0.75)
                                    .foregroundColor(.black)
                            }
                    }
                    .padding(.top, 12)

                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        Button("Sign Up") {
                            showSignUp = true
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
        .sheet(isPresented: $showSignUp) {
            SignUpView(authViewModel: authViewModel)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authViewModel: AuthViewModel(userViewModel: UserViewModel()))
    }
}

