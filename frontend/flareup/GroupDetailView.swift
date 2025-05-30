import SwiftUI

struct GroupDetailView: View {
    let group: GroupModel
    @State private var isFlareToggled = false

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "FFF4E9").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Color.clear.frame(height: 90)

                    HStack {
                        Text(group.name)
                            .font(.custom("Poppins-Bold", size: 28))
                            .foregroundColor(Color(hex: "F7941D"))
                            .padding(.horizontal)

                        Spacer()

                        Button(action: {
                            isFlareToggled = true
                        }) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color(hex: "F25D29"), Color(hex: "F7941D")]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .shadow(color: Color.orange.opacity(0.4), radius: 6, x: 0, y: 2)
                        }
                        .padding(.top, -8)
                        .padding(.trailing, 20)
                    }

                    // Drop Summary Card
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Latest \(group.name) Drop")
                                .font(.custom("Poppins-Bold", size: 22))
                                .foregroundColor(Color(hex: "F7941D"))
                            Spacer()
                            Text("May 2")
                                .font(.custom("Poppins-Bold", size: 20))
                                .foregroundColor(Color(hex: "F7941D"))
                        }

                        Text("\(group.name) were on their phones for a total of \(mockGroupTotalHours[group.name] ?? 57) Hours last week!")
                            .font(.custom("Poppins-Regular", size: 18))
                            .foregroundColor(Color(hex: "F25D29"))

                        HStack(spacing: 8) {
                            Text("\(mockGroupChange[group.name] ?? "+7%")")
                                .foregroundColor(mockGroupChange[group.name]?.hasPrefix("-") == true ? .green : .red)
                                .fontWeight(.bold)
                                .font(.custom("Poppins-Bold", size: 20))

                            Text("change from the previous drop!")
                                .foregroundColor(.gray)
                                .font(.custom("Poppins-Bold", size: 16))
                        }

                        HStack(spacing: 8) {
                            Text("Wager")
                                .foregroundColor(.green)
                                .font(.custom("Poppins-Bold", size: 18))
                            Text(mockGroupWager[group.name] ?? "Dinner")
                                .foregroundColor(.gray)
                                .font(.custom("Poppins-Bold", size: 18))
                                .underline()
                        }

                        HStack(spacing: 8) {
                            Image(mockGroupLoserImage[group.name] ?? "")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                            Text("This week's loser is.. \(mockGroupLoserName[group.name] ?? "")! With a total of \(mockGroupLoserHours[group.name] ?? 42) hours last week")
                                .font(.custom("Poppins-Regular", size: 17))
                                .foregroundColor(Color(hex: "F25D29"))
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(radius: 3)
                    .padding(.horizontal)

                    // Members section
                    HStack {
                        Text("members")
                            .font(.custom("Poppins-Bold", size: 26))
                            .foregroundColor(Color(hex: "F7941D"))
                        Spacer()
                        Button(action: {}) {
                            Text("+ add members")
                                .font(.custom("Poppins-Bold", size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "F25D29"))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)

                    VStack(spacing: 16) {
                        let sortedMembers = group.members.sorted {
                            (mockGroupMemberHours[group.name]?[$0] ?? 0) >
                            (mockGroupMemberHours[group.name]?[$1] ?? 0)
                        }

                        ForEach(Array(sortedMembers.enumerated()), id: \.offset) { index, member in
                            let displayName = member
                                .replacingOccurrences(of: "Pic", with: "")
                                .replacingOccurrences(of: "profile", with: "scott")

                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.custom("Poppins-Bold", size: 18))
                                    .foregroundColor(Color(hex: "F7941D"))

                                Image(member)
                                    .resizable()
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color(hex: "F7941D"), lineWidth: 2))

                                Text(" " + displayName)
                                    .font(.custom("Poppins-Bold", size: 23))
                                    .foregroundColor(Color(hex: "F7941D"))

                                Spacer()

                                Text("\(mockGroupMemberHours[group.name]?[member] ?? 0) hours  ")
                                    .font(.custom("Poppins-Regular", size: 20))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(hex: "FFF5E9"))
                            .cornerRadius(50)
                            .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
                .background(Color.white)
            }

            // Fixed FlareUp header
            FlareupHeader {}

            if isFlareToggled {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isFlareToggled = false
                    }

                VStack(spacing: 16) {
                    Text("Flared \(group.name)!")
                        .font(.custom("Poppins-Bold", size: 22))
                        .foregroundColor(Color(hex: "F25D29"))

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(group.members, id: \.self) { member in
                            let cleanName = member
                                .replacingOccurrences(of: "Pic", with: "")
                                .replacingOccurrences(of: "profile", with: "scott")

                            Text("• " + cleanName)
                                .font(.custom("Poppins-Regular", size: 18))
                                .foregroundColor(.black)
                        }
                    }

                    Button("Close") {
                        isFlareToggled = false
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "F25D29"))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal, 40)
                .transition(.scale)
            }
        }
    }
}




// Mock data to simulate backend
let mockGroupTotalHours: [String: Int] = [
    "The Chuzz": 57,
    "HCI 4 Lyfe": 96,
    "CS188TAS": 132
]

let mockGroupChange: [String: String] = [
    "The Chuzz": "-7%",
    "HCI 4 Lyfe": "+6%",
    "CS188TAS": "+13%"
]

let mockGroupWager: [String: String] = [
    "The Chuzz": "Dinner @ Din Tai Fung",
    "HCI 4 Lyfe": "Bake brownies",
    "CS188TAS": "Grade all W9 assignments"
]

let mockGroupLoserName: [String: String] = [
    "The Chuzz": "Richelle",
    "HCI 4 Lyfe": "Scott",
    "CS188TAS": "Ollie"
]

let mockGroupLoserImage: [String: String] = [
    "The Chuzz": "richellePic",
    "HCI 4 Lyfe": "profilePic",
    "CS188TAS": "olliePic"
]

let mockGroupLoserHours: [String: Int] = [
    "The Chuzz": 42,
    "HCI 4 Lyfe": 53,
    "CS188TAS": 74
]

let mockGroupMemberHours: [String: [String: Int]] = [
    "The Chuzz": ["richellePic": 41, "abrilPic": 12, "daltonPic": 21],
    "HCI 4 Lyfe": ["emjunPic": 9, "abrilPic": 12, "profilePic": 33],
    "CS188TAS": ["emjunPic": 9, "olliePic": 63, "hangerPic": 55]
]
#Preview {
    SocialView()
}
