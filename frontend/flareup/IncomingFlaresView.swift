import SwiftUI

struct IncomingFlaresView: View {
    struct Flare {
        let sender: String
        let avatar: String
        let moodIcon: String
        let moodText: String
        let message: String
        let nameColor: Color
    }

    let flares: [Flare] = [
        Flare(sender: "abril", avatar: "abrilpic", moodIcon: "🧠", moodText: "nerding", message: "Someone please come to Powell and study with me", nameColor: Color(hex: "F67653")),
        Flare(sender: "richelle", avatar: "richellePic", moodIcon: "😎", moodText: "chill", message: "Cafe Anyone? Got some mickey mouse work to do", nameColor: Color(hex: "F67653"))
    ]
    @StateObject private var viewModel = CountdownViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            FlareupHeader {}

            // Countdown bar under header
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
            // end of header
            
            HStack {
                Button(action: {
                    // go back
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "F7941D"))
                }
                Text("incoming flares")
                    .font(.custom("Poppins-Bold", size: 32))
                    .foregroundColor(Color(hex: "F7941D"))
                Spacer()
            }
            .padding()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(flares, id: \.sender) { flare in
                        HStack(alignment: .center, spacing: 12) {
                            Image(flare.avatar)
                                .resizable()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(flare.sender)
                                        .font(.custom("Poppins-Bold", size: 32))
                                        .foregroundColor(flare.nameColor)

                                    Spacer()

                                    Text("\(flare.moodIcon) \(flare.moodText)")
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(.gray)
                                }

                                Text("\"\(flare.message)\"")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.gray)
                                    .padding(10)
                                    .background(Color(hex: "F6EEE2"))
                                    .cornerRadius(20)
                            }
                        }
                        .padding()
                        .background(Color(hex: "FFF2E2"))
                        .cornerRadius(28)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    IncomingFlaresView()
        .environmentObject(SessionViewModel())
}
