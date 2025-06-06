import SwiftUI
import UIKit// for img picker
import Supabase

struct UserMetadata: Encodable {
    let id: String
    let email: String
    let username: String
    let goal_screen_time: Int
    let profile_picture: String
}


struct SignupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var session: SessionViewModel

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var stGoal: Int = 1 // Screen time goal
    @State private var profileImage: UIImage? = nil
    @State private var isPickerPresented = false
    @State private var showAlert = false
    @State private var alertMessage = ""

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
                    .frame(height: 100)
                    
                    // FORM section
                    VStack(spacing: 14) {
                        
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
                                .offset(y:10)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, -12)
                        
                        Text("Sign Up")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AccentRed"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 28)
                        VStack {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }

                            Button("Upload Profile Picture") {
                                isPickerPresented = true
                            }
                            .font(.footnote)
                        }
                        .sheet(isPresented: $isPickerPresented) {
                            ImagePicker(image: $profileImage)
                        }

                        HStack(spacing: 12) {
                            Image("LogInPerson")
                                .renderingMode(.template)
                                .foregroundColor(.gray)

                            TextField("Username", text: $username)
                                .foregroundColor(.blue)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
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
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled(true)
                                .font(.custom("Poppins-Regular", size: 15))
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
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .font(.custom("Poppins-Regular", size: 15))
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
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .font(.custom("Poppins-Regular", size: 15))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(30)
                        .padding(.horizontal, 28)
                        
                        HStack(spacing: 6) {
                            Text(" Daily Screen \n Time Goal")
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
                            Task {
                                guard password == confirmPassword else {
                                    alertMessage = "Passwords do not match"
                                    showAlert = true
                                    return
                                }

                                do {
                                    var profileBase64: String? = nil
                                    if let image = profileImage,
                                       let imageData = image.jpegData(compressionQuality: 0.8) {
                                        profileBase64 = imageData.base64EncodedString()
                                    }

                                    let payload: [String: Any] = [
                                        "email": email,
                                        "password": password,
                                        "username": username,
                                        "goal_screen_time": stGoal,
                                        "profile_picture": profileBase64 ?? ""
                                    ]

                                    let jsonData = try JSONSerialization.data(withJSONObject: payload)

                                    guard let url = URL(string: "http://localhost:4000/users/signup") else {
                                        alertMessage = "Invalid server URL"
                                        showAlert = true
                                        return
                                    }

                                    var request = URLRequest(url: url)
                                    request.httpMethod = "POST"
                                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                    request.httpBody = jsonData

                                    let (data, response) = try await URLSession.shared.data(for: request)

                                    guard let httpResponse = response as? HTTPURLResponse else {
                                        alertMessage = "Invalid response from server"
                                        showAlert = true
                                        return
                                    }

                                    if httpResponse.statusCode == 201 {
                                        print("Signup successful!")
                                        await session.login(email: email, password: password)
                                        dismiss()
                                    } else {
                                        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                           let errorMsg = json["error"] as? String {
                                            alertMessage = "Signup failed: \(errorMsg)"
                                        } else {
                                            let responseText = String(data: data, encoding: .utf8) ?? "Unable to decode server response"
                                            alertMessage = "Signup failed: Unexpected response\n\n\(responseText)"
                                        }
                                        showAlert = true
                                    }

                                } catch {
                                    alertMessage = "Signup failed: \(error.localizedDescription)"
                                    showAlert = true
                                }
                            }
                        }) {
                            Text("Sign Up")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentRed"))
                                .cornerRadius(30)
                                .padding(.horizontal, 28)
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Signup Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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
                    .offset(y:20)
                    .frame(maxWidth: .infinity)
                    .background(Color("LightComponent"))
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .ignoresSafeArea(edges: .bottom)
                }
                .offset(y:40)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    SignupView()
}
