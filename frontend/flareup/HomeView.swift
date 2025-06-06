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
            .frame(width: 28, height: 28)
            .background(Color(hex: "FFECDD"))
            .cornerRadius(8)
    }
}

struct ScreenTimeEntry: Codable {
    let duration: Int
    let date: String
    let category: String
}

struct DropData: Codable {
    let date: String
    let total_minutes: Int
    let average_daily_hours: Double
    let weekly_change: Double?
    let most_used_app: String?
    let most_used_app_minutes: Int?
    let missing_this_week: Bool
    let missing_last_week: Bool
}

struct HomeView: View {

    @StateObject private var viewModel = CountdownViewModel()
    @EnvironmentObject var session: SessionViewModel
    @State private var drop: DropData? = nil

    var body: some View {
        VStack(spacing: 0) {
            FlareupHeader {}

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
            .padding(.top, -90)
            .background(Color(hex: "FFF2E2"))
            .padding(.bottom, 8)

            ScrollView {
                ZStack(alignment: .top) {
                    Color.white
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .offset(y: -30)
                        .padding(.top, -25)
                }

                VStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Stats")
                            .font(.custom("Poppins-Bold", size: 25))
                            .foregroundColor(Color(hex: "F7941D"))

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

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Latest Drop")
                                .font(.custom("Poppins-Bold", size: 25))
                                .foregroundColor(Color(hex: "F7941D"))

                            Spacer()

                            Text(drop?.date ?? currentDay)
                                .font(.custom("Poppins-Bold", size: 24))
                                .foregroundColor(Color(hex: "F7941D"))
                        }

                        if drop?.missing_this_week == true {
                            Text("You didn't input your data this week.")
                                .font(.custom("Poppins-Regular", size: 14.4))
                                .foregroundColor(.gray)
                        } else if let mins = drop?.total_minutes {
                            Text("You were on your phone for \(mins / 60) Hours last week!")
                                .font(.custom("Poppins-Regular", size: 14.4))
                                .foregroundColor(.gray)

                            if let change = drop?.weekly_change {
                                HStack(spacing: 6) {
                                    Text(String(format: "%.0f%%", change * 100))
                                        .foregroundColor(change < 0 ? .green : .red)
                                        .fontWeight(.bold)
                                    Text("change from the previous drop!")
                                        .foregroundColor(.gray)
                                }
                            } else {
                                Text("Last week, you didn't input your data. Welcome back!")
                                    .font(.custom("Poppins-Regular", size: 14.4))
                                    .foregroundColor(.gray)
                            }

                            HStack(spacing: 6) {
                                Text(String(format: "%.2f", drop!.average_daily_hours))
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                                Text("average daily usage")
                                    .foregroundColor(.gray)
                            }

                            if let app = drop?.most_used_app, let min = drop?.most_used_app_minutes {
                                HStack(spacing: 8) {
                                    Image("flareUpLogo_icon")
                                        .resizable()
                                        .frame(width: 36, height: 36)

                                    Text("\(app) was your most used app at ").font(.custom("Poppins-Regular", size: 19)) + Text("\(Double(min) / 60, specifier: "%.1f") hours!").font(.custom("Poppins-Bold", size: 19))
                                }
                                .font(.footnote)
                                .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .padding(.top, -5)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(session.friends, id: \ .id) { friend in
                                VStack(spacing: 4) {
                                    Text("   ")
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, -4)
                        .padding(.top, -10)
                    }
                }
                .padding(.top)
            }
            .onAppear {
                Task {
                    await fetchDrop()
                }
            }
        }
    }

func fetchDrop() async {
    guard let url = URL(string: "http://localhost:4000/drops/latest/\(session.userId)") else { return }
    var request = URLRequest(url: url)
    request.setValue("Bearer \(session.authToken)", forHTTPHeaderField: "Authorization")

    do {
        let (data, response) = try await URLSession.shared.data(for: request)

        // TEMP: Inspect raw data
        if let string = String(data: data, encoding: .utf8) {
            print("📦 Raw drop response:", string)
        }

        let decoded = try JSONDecoder().decode(DropData.self, from: data)
        drop = decoded
    } catch {
        print("Drop fetch failed:", error.localizedDescription)
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
