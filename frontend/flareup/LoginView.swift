import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
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
                            
                            TextField("eunice @g.com", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled(true)
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
                        
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            
                            SecureField("Password", text: $password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .font(.custom("Poppins-Regular", size: 15))
                        }
                        .padding(.leading, 16)
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(28)
                        .shadow(color: .black.opacity(0.1), radius: 2.65, x: -1, y: 2.5)
                        .padding(.horizontal, 28)
                        
                        HStack {
                            Spacer()
                            Text("Forgot password?")
                                .font(Font.custom("Poppins", size: 15).weight(.light))
                                .foregroundColor(Color(red: 0.54, green: 0.55, blue: 0.57))
                            Button("Reset") {
                                // Handle reset action
                            }
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.54, green: 0.55, blue: 0.57))
                        }
                        .padding(.horizontal, 28)
                        
                        Button(action: {
                            Task {
                                await handleSignIn()
                            }
                        }) {
                            Text("Sign In")
                                .font(.custom("Poppins-SemiBold", size: 15))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color("AccentRed"))
                                .cornerRadius(28)
                        }
                        .padding(.horizontal, 28)
                        
                        HStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 112, height: 1)
                                .background(Color(red: 0.79, green: 0.79, blue: 0.79))
                            
                            Text("or login with")
                                .font(Font.custom("Poppins", size: 13).weight(.light))
                                .foregroundColor(Color(red: 0.54, green: 0.55, blue: 0.57))
                            
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 112, height: 1)
                                .background(Color(red: 0.79, green: 0.79, blue: 0.79))
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 30)
                        
                        Button {
                            // Handle Apple login
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
                            
                            NavigationLink(destination: SignupView()) {
                                Text("Sign Up")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("AccentRed"))
                            }
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
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(session.errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
                
            }
        }
    }

    private func handleSignIn() async {
        do {
            try await session.signIn(email: email, password: password)
        } catch {
            showAlert = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(SessionViewModel())
    }
}

#Preview {
    LoginView()
}
