import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: SessionViewModel

    @State private var isEditing = false
    @State private var showingScreenTimeInput = false
    @State private var statusMessage = "\u{1F512} locked in"
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var screentimeGoal: String = ""
    @State private var streakCount = 42
    @State private var showLogoutDialog = false

    

    let days: [(String, Int)] = [("S", 21), ("M", 22), ("T", 23), ("W", 24), ("T", 25), ("F", 26), ("S", 27)]
    let successful: Set<Int> = [21, 22, 23, 24]
    let today = 25

    var body: some View {
        ZStack {
            if isEditing {
                ProfileEditSubview(
                    isEditing: $isEditing,
                    name: $name,
                    username: $username,
                    statusMessage: $statusMessage,
                    screentimeGoal: $screentimeGoal
                )
            } else {
                //fill above logo
                Color(hex: "FFF2E2")
                    .frame(height: 150) // adjust as needed
                    .ignoresSafeArea(edges: .top)
                    .offset(y:-350)
                ScrollView {
                    VStack(spacing: 0) {
                        FlareupHeader {}
                        
                        ZStack(alignment: .bottomLeading) {
                            Color(hex: "F7941D")
                                .frame(height: 170)
                                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                                .offset(y: 0)
                            
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 0) {
                                    VStack(spacing: 8) {
                                        Button("Edit") {
                                            isEditing = true
                                        }
                                        .font(.custom("Poppins-SemiBold", size: 20))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Color(hex: "FFECDD"))
                                        .foregroundColor(Color(hex: "F25D29"))
                                        .cornerRadius(8)
                                        .offset(x:-20,y:20)
                                    }
                                    .offset(x:15,y: -25)// edit
                                    
                                    VStack(spacing:-5) {
                                        Text(name)
                                            .font(.custom("Poppins-Bold", size: 33))
                                            .foregroundColor(.white)
                                        Text("  "+username)
                                            .font(.custom("Poppins-Regular", size: 22))
                                            .foregroundColor(.white)
                                    }
                                    .offset(x:-10,y: 10)// name $ username
                                }
                                
                                Spacer()
                                
                                ZStack(alignment: .bottomTrailing) {
                                    Image("defaultPfp")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150, height: 150)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color(hex: "F7941D"), lineWidth: 8))
                                    
                                    Text("\(streakCount)")
                                        .font(.custom("Poppins-Bold", size: 32))
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color(hex: "F25D29"))
                                        .clipShape(Circle())
                                        .offset(x: 10, y: 10)
                                }.offset(y: -55) //prof pic
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                
                        // Status Message
                        VStack(alignment: .leading, spacing: 8) {
                            
                            // Status Message Bubble
                            VStack(spacing: 4) {
                                Bubble(diameter: 45).offset(x: 145, y: -172)
                                Bubble(diameter: 18).offset(x: 190, y: -226)
                            }
                            HStack {
                                Text(statusMessage)
                                    .font(.custom("Poppins-Regular", size: 22))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 8)
                                    .background(Color(red: 1.0, green: 0.78, blue: 0.58))
                                    .cornerRadius(24)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .offset(x:59,y: -230)
                            
                            // Target Screen Time
                            HStack(spacing: 6) {
                                Image(systemName: "target")
                                Text(screentimeGoal)
                            }
                            .font(.custom("Poppins-Regular", size: 26))
                            .foregroundColor(.white)
                            .offset(x:225,y: -165)
                        }
                        .padding(.horizontal)
                        .offset(x:-5,y: -20)
                        
                        // Calendar streak
                        HStack(spacing: 12) {
                            ForEach(days, id: \.1) { (day, number) in
                                VStack {
                                    Text(day)
                                        .font(.custom("Poppins-Regular", size: 18))
                                        .foregroundColor(.gray)
                                    
                                    Text("\(number)")
                                        .font(.custom("Poppins-Bold", size: 18))
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle().fill(successful.contains(number) ? Color(hex: "46C97A") : (number == today ? Color.white : Color.gray.opacity(0.1)))
                                        )
                                        .overlay(
                                            Circle().stroke(Color.black.opacity(number == today ? 0.7 : 0), lineWidth: 2)
                                        )
                                        .foregroundColor(number == today ? .black : .white)
                                }
                            }
                        }
                        .padding(.vertical, 0)
                        .offset(y:-140)
                        
                        Button(action: {
                            showingScreenTimeInput = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Enter Your Screen Time!")
                                        .font(.custom("Poppins-Bold", size: 20))
                                        .foregroundColor(.white)
                                    Text("you still haven’t submitted\nyour weekly screen time data\nfor the latest drop")
                                        .font(.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(.white.opacity(0.85))
                                }

                                Spacer()

                                Text("add")
                                    .font(.custom("Poppins-Bold", size: 18))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .foregroundColor(Color(hex: "F25D29"))
                                    .cornerRadius(30)
                            }
                            .padding()
                            .background(Color(hex: "F25D29"))
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }
                        .offset(y: -120)
                        
                        // Streak summary
                        HStack(alignment: .center, spacing: 12) {
                            Text("\(streakCount)")
                                .font(.custom("Poppins-Bold", size: 32))
                                .padding(12)
                                .background(Color(hex: "FFECDD"))
                                .cornerRadius(16)
                                .foregroundColor(Color(hex: "F25D29"))
                            
                            Text("You are currently on a \(streakCount) day streak in reaching your 3 hour daily screen time goal!")
                                .font(.custom("Poppins-Regular", size: 17))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 1)
                        .padding(.horizontal)
                        .offset(y:-100)
                        
                        // Latest Drop Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Latest Personal Drop")
                                    .font(.custom("Poppins-Bold", size: 22))
                                    .foregroundColor(Color(hex: "F7941D"))

                                Spacer()

                                Text(currentDay)
                                    .font(.custom("Poppins-Bold", size: 22))
                                    .foregroundColor(Color(hex: "F7941D"))
                            }

                            Text("You were on your phone for 12 Hours last week!")
                                .font(.custom("Poppins-Regular", size: 14.4))
                                .foregroundColor(.gray)

                            HStack(spacing: 6) {
                                Text("23%")
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                                Text("decrease from the previous drop!")
                                    .foregroundColor(.gray)
                            }

                            HStack(spacing: 6) {
                                Text("1.57x")
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                                Text("lower than your friends!")
                                    .foregroundColor(.gray)
                            }

                            HStack(spacing: 6) {
                                Text("0x")
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                                Text("group wagers lost!")
                                    .foregroundColor(.gray)
                            }

                            HStack(spacing: 6) {
                                Text("7x")
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                                Text("perfect streak!")
                                    .foregroundColor(.gray)
                            }

                            HStack(spacing: 6) {
                                Text("216x")
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                                Text("average daily pickups")
                                    .foregroundColor(.gray)
                            }

                            HStack(spacing: 6) {
                                Text("108x")
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                                Text("average daily notifications")
                                    .foregroundColor(.gray)
                            }

                            HStack(spacing: 8) {
                                Image("flareUpLogo_icon")
                                    .resizable()
                                    .frame(width: 36, height: 36)

                                Text("flareup was your most used app at ")
                                    .font(.custom("Poppins-Regular", size: 19)) +
                                Text("3.2 hours!")
                                    .font(.custom("Poppins-Bold", size: 19))
                            }
                            .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 1)
                        .padding(.horizontal)
                        .offset(y:-80)
                    }
                }
            }
        }
        .sheet(isPresented: $showingScreenTimeInput) {
            ScreenTimeInputView()
        }
        .onAppear {
            if let user = session.currentUser {
                name = user.username ?? "Name"
                username = user.username
                screentimeGoal = "\(user.goal_screen_time) Hours"
            }
        }
    }
}

struct ProfileEditSubview: View {
    @Binding var isEditing: Bool
    @Binding var name: String
    @Binding var username: String
    @Binding var statusMessage: String
    @Binding var screentimeGoal: String
    @State private var showingSignOutAlert = false
    @State private var isSigningOut = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var session: SessionViewModel


    var body: some View {
        ZStack {
            Color(hex: "FFF2E2") // light orange
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    Spacer(minLength: -16)
                    // Header
                    VStack(spacing: 0) {
                        FlareupHeader {}
                        Button(action: {
                            isEditing = false
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                        }
                        .offset(x:-170,y:10)
                        
                        Color(hex: "F7941D")
                            .frame(height: 220)
                            .overlay(
                                VStack(spacing: 12) {
                                    ZStack(alignment: .bottomTrailing) {
                                        Image("defaultPfp")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 110, height: 110)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                        
                                        Button("change") {
                                            // handle change pic
                                        }
                                        .font(.custom("Poppins-SemiBold", size: 20))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.white)
                                        .foregroundColor(Color(hex: "F7941D"))
                                        .cornerRadius(10)
                                        .offset(x: -16, y: 45)
                                    }
                                }
                                .offset(y: -70)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        editField(label: "Name", text: $name)
                        editField(label: "Username", text: $username)
                        editField(label: "Status Message", text: $statusMessage)
                        editField(label: "Daily Screentime Goal", text: $screentimeGoal)
                    }
                    .offset(y:-60)
                    .padding(.horizontal)
                    .padding(.top, -10)
                    .background(Color(hex: "F7941D"))
                    
                    Button("Save") {
                        isEditing = false
                    }
                    .font(.custom("Poppins-Bold", size: 18))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .foregroundColor(Color(hex: "F25D29"))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .offset(y:-60)
                    
                    Button(action: {
                        showingSignOutAlert = true
                    }) {
                        HStack {
                            Text("Sign Out")
                                .font(.custom("Poppins-Bold", size: 18))
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.red)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .offset(y:-50)
                    
                    Spacer()
                }
                .background(Color(hex: "F7941D"))
                .ignoresSafeArea(edges: .bottom)
            }
        }
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

    @ViewBuilder
    private func editField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.white)

            TextField("", text: text)
                .font(.custom("Poppins-Regular", size: 16))
                .padding()
                .background(Color(hex: "FFECDD"))
                .cornerRadius(20)
                .foregroundColor(.white)
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

struct Bubble: View {
    var diameter: CGFloat = 30
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0

    var body: some View {
        Circle()
            .fill(Color(red: 1.0, green: 0.78, blue: 0.58))
            .frame(width: diameter, height: diameter)
            .offset(x: offsetX, y: offsetY)
    }
}

#Preview {
    ProfileView()
}
