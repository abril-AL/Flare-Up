import SwiftUI

var currentDay: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter.string(from: Date())
}

struct TimeBlockView: View {
    let value: String

    var body: some View {
        Text(value)
            .font(.custom("Poppins-Bold", size: 20))
            .foregroundColor(Color(hex: "F25D29"))
            .frame(width: 28, height:28)
            .background(Color(hex: "FFECDD"))
            .cornerRadius(8)
    }
}

struct HomeView: View {
    
    @StateObject private var viewModel = CountdownViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
                FlareupHeader {} 

                // Countdown lives just under the header
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("next drop")
                            .font(.custom("Poppins-Regular", size: 18))
                            .foregroundColor(Color(hex: "F25D29"))

                        HStack(spacing: 6) {
                            TimeBlockView(value: viewModel.days)
                            TimeBlockView(value: viewModel.hours)
                            TimeBlockView(value: viewModel.minutes)
                            TimeBlockView(value: viewModel.seconds)
                        }
                    }
                    .padding(.trailing)
                }
                .padding(.top, -90) // pull upward to nest against the header
                .background(Color(hex: "FFF2E2")) // match header color
                .padding(.bottom, 8) // spacing before scrollView

            ScrollView {
                ZStack(alignment: .top) {
                    // White block that pulls up under header
                    Color.white
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .offset(y: -30) // pull upward
                        .padding(.top, -25) // match the offset (cancel out scroll clipping)
                }
                VStack(spacing: 15) {
                    // Your Stats Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Stats")
                            .font(.custom("Poppins-Bold", size: 25))
                            .foregroundColor(Color(hex: "F7941D")) // Figma orange

                        Text("You currently have 3 hours left before you reach your daily screen time limit.")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.gray)

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.2))
                                .frame(height: 20)

                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange)
                                .frame(width: UIScreen.main.bounds.width * 0.6, height: 20)
                        }

                        Text("You are currently on a 42 day streak in reaching your screen time goal!")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    .padding(.top, -10)

                    // Latest Drop Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Latest Drop")
                                .font(.custom("Poppins-Bold", size: 25))
                                .foregroundColor(Color(hex: "F7941D")) // Figma orange

                            Spacer()

                            Text(currentDay)
                                .font(.custom("Poppins-Bold", size: 24))
                                .foregroundColor(Color(hex: "F7941D")) // Figma orange
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

                        HStack(spacing: 8) {
                            Image("flareUpLogo_icon")
                                .resizable()
                                .frame(width: 36, height: 36)

                            Text("flareup was your most used app at ").font(.custom("Poppins-Regular", size: 19)) + Text("3.2 hours!").font(.custom("Poppins-Bold", size: 19))
                        }
                        .font(.footnote)
                        .foregroundColor(.orange)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    .padding(.vertical,5)
                    .padding(.top, -5)

                    // Friends Rankings
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(friendSampleData, id: \ .id) { friend in
                                VStack(spacing: 4) {
                                    Text("   ")// space bc im dumb and idk how to fix
                                        .font(.custom("Poppins-Bold", size: 1))
                                        .padding(.bottom, 10)
                                        .foregroundColor(.gray)
                                    
                                    Image(friend.imageName)
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(friend.rank == 4 ? Color.orange : Color.clear, lineWidth: 2)
                                        )
                                    
                                    Text("\(friend.rank)")
                                        .font(.custom("Poppins-Bold", size: 15))
                                        .foregroundColor(Color(hex: "F7941D"))

                                    Text(friend.name)
                                        .font(.custom("Poppins-Bold", size: 15))
                                        .foregroundColor(Color(hex: "F7941D"))
                                        .lineLimit(1)

                                    Text("\(friend.hours) hours")
                                        .font(.custom("Poppins-Bold", size: 10))
                                        .padding(.bottom, 2)
                                        .foregroundColor(.gray)
                                    
                                }
                            }
                        }
                        .padding(.horizontal,16)
                        .padding(.vertical,-4)
                        .padding(.top, -10)
                    }
                }
                .padding(.top)
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

struct Friend: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let hours: Int
    let imageName: String
}

let friendSampleData = [
    Friend(rank: 1, name: "emjun", hours: 9, imageName: "emjunPic"),
    Friend(rank: 2, name: "abril", hours: 12, imageName: "abrilPic"),
    Friend(rank: 3, name: "dalton", hours: 21, imageName: "daltonPic"),
    Friend(rank: 4, name: "scotty", hours: 33, imageName: "profilePic"),
    Friend(rank: 5, name: "richelle", hours: 41, imageName: "richellePic"),
    Friend(rank: 6, name: "hanger", hours: 55, imageName: "hangerPic"),
    Friend(rank: 5, name: "ollie", hours: 63, imageName: "olliePic")
]

#Preview {
    HomeView()
}
