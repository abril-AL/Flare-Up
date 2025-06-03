import SwiftUI

struct DropSummaryCard: View {
    let date: String
    let totalHours: Double
    let averageHours: Double
    let weeklyChange: Double?
    let mostUsedApp: String?
    let mostUsedAppHours: Double?
    let isMissingThisWeek: Bool
    let isMissingLastWeek: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Latest Drop")
                    .font(.custom("Poppins-Bold", size: 22))
                    .foregroundColor(Color(hex: "F7941D"))
                Spacer()
                Text(date)
                    .font(.custom("Poppins-Bold", size: 20))
                    .foregroundColor(Color(hex: "F7941D"))
            }

            if isMissingThisWeek {
                Text("You didn't input your data this week.")
                    .font(.custom("Poppins-Regular", size: 18))
                    .foregroundColor(.gray)
            } else if isMissingLastWeek {
                Text("Welcome back! You were on your phone for \(formattedHours(totalHours)) last week!")
                    .font(.custom("Poppins-Regular", size: 18))
                    .foregroundColor(Color(hex: "F25D29"))
            } else {
                Text("You were on your phone for \(formattedHours(totalHours)) last week!")
                    .font(.custom("Poppins-Regular", size: 18))
                    .foregroundColor(Color(hex: "F25D29"))

                if let change = weeklyChange {
                    HStack {
                        Text("\(Int(abs(change * 100)))%")
                            .foregroundColor(change < 0 ? .green : .red)
                            .font(.custom("Poppins-Bold", size: 20))
                        Text(change < 0 ? "decrease from the previous drop!" : "increase from the previous drop!")
                            .foregroundColor(.gray)
                            .font(.custom("Poppins-Bold", size: 16))
                    }
                }

                Text("Avg daily usage: \(String(format: "%.1f", averageHours)) hrs/day")
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.gray)

                if let app = mostUsedApp, let appHours = mostUsedAppHours {
                    HStack {
                        Image("flareup") // 🔁 Replace with actual logo image
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("\(app) was your most used app at ")
                            .foregroundColor(Color(hex: "F25D29"))
                        + Text("\(formattedHours(appHours))!")
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "F25D29"))
                    }
                    .font(.custom("Poppins-Regular", size: 16))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(24)
        .shadow(radius: 3)
        .padding(.horizontal)
    }

    private func formattedHours(_ minutes: Double) -> String {
        let hours = minutes / 60
        return String(format: "%.1f hours", hours)
    }
}
