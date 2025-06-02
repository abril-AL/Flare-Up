import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) var dismiss

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var stGoal: Int = 1 // Screen time goal

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundOrange")
                    .ignoresSafeArea()

                VStack() {
                    // TOP section (taller + shifted bubble)
                    VStack {
                        HStack {
                            Image("ThinkingLogo")
                                .resizable()
                                .frame(width: 326, height: 103.67)
                            Spacer()
                        }
                        .padding(.horizontal)

                    }
                    .frame(height: 220)
                    
                    // FORM section
                    VStack(spacing: 20) {
                        
                        // Back to Login Page
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("back to Login")
                                        .font(.system(size: 14))
                                        .textCase(.lowercase)
                                }
                                .foregroundColor(Color.gray)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, -12)
                        
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

                            TextField("Username", text: $username)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(30)
                        .padding(.horizontal, 28)

                        HStack(spacing: 12) {
                            Image("LogInLock")
                                .renderingMode(.template)
                                .foregroundColor(.gray)

                            TextField("Email", text: $email)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(30)
                        .padding(.horizontal, 28)

                        HStack(spacing: 12) {
                            Image("LogInLock")
                                .renderingMode(.template)
                                .foregroundColor(.gray)

                            SecureField("Password", text: $password)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(30)
                        .padding(.horizontal, 28)

                        HStack(spacing: 12) {
                            Image("LogInLock")
                                .renderingMode(.template)
                                .foregroundColor(.gray)

                            SecureField("Confirm Password", text: $confirmPassword)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(30)
                        .padding(.horizontal, 28)
                        
                        VStack(spacing: 6) {
                            Text(" Daily Screen Time Goal (hrs)")
                                .font(.custom("Poppins-Regular", size: 17))
                                .foregroundColor(Color("AccentRed"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 28)

                            Picker("Screen Time Goal", selection: $stGoal) {
                                ForEach(1..<13) { hour in
                                    Text("\(hour) hour\(hour == 1 ? "" : "s")").tag(hour)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(30)
                            .padding(.horizontal, 28)
                        }

                        Button(action: {
                            // Sign-up logic here -idk im frontend
                        }) {
                            Text("Sign Up")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentRed"))
                                .cornerRadius(30)
                                .padding(.horizontal, 28)
                        }
                        
                        Button(action: {
                        }) {
                            Text("bruh") // ignore this
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentRed"))
                                .cornerRadius(30)
                                .padding(.horizontal, 28)
                        }
                        .offset(y:40)
                    }
                    .offset(y:30)
                    .frame(maxWidth: .infinity)
                    .background(Color("LightComponent"))
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .ignoresSafeArea(edges: .bottom)
                }
                .offset(y:-50)
            }
        }
    }
}
#Preview {
    SignupView()
}
