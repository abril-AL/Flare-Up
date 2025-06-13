import SwiftUI

struct IncomingFlare: Identifiable, Decodable {
    let id: UUID
    let status: String
    let note: String?
    let sender: Sender

    struct Sender: Decodable {
        let id: UUID
        let name: String
        let username: String
        let profile_picture: String
    }
}

struct IncomingFlaresView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var flares: [IncomingFlare] = []
    @StateObject private var countdown = CountdownViewModel()

    var body: some View {
        VStack(spacing: 0) {
            FlareupHeader {}

            CountdownSection(countdown: countdown)

            TitleBar()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(flares) { flare in
                        IncomingFlareCard(flare: flare)
                    }
                }
                .padding(.top)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            Task {
                await session.loadIncomingFlares()
                flares = session.incomingFlares
            }
        }
    }
}

struct CountdownSection: View {
    @ObservedObject var countdown: CountdownViewModel

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("next drop")
                    .font(.custom("Poppins-Regular", size: 18))
                    .foregroundColor(Color(hex: "F25D29"))

                HStack(spacing: 6) {
                    TimeBlockView(value: countdown.days)
                    TimeBlockView(value: countdown.hours)
                    TimeBlockView(value: countdown.minutes)
                    TimeBlockView(value: countdown.seconds)
                }
            }
            .padding(.trailing)
        }
        .padding(.top, -90)
        .background(Color(hex: "FFF2E2"))
        .padding(.bottom, 8)
    }
}

struct TitleBar: View {
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color(hex: "F7941D"))
            }

            Text("incoming flares")
                .font(.custom("Poppins-Bold", size: 32))
                .foregroundColor(Color(hex: "F7941D"))
            Spacer()
        }
        .padding()
    }
}

struct IncomingFlareCard: View {
    let flare: IncomingFlare

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            flareImage(named: flare.sender.profile_picture)
                .resizable()
                .frame(width: 90, height: 90)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(flare.sender.name)
                        .font(.custom("Poppins-Bold", size: 32))
                        .foregroundColor(Color(hex: "F67653"))

                    Spacer()

                    Text(flare.status)
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.gray)
                }

                if let note = flare.note, !note.isEmpty {
                    Text("\"\(note)\"")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.gray)
                        .padding(10)
                        .background(Color(hex: "F6EEE2"))
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color(hex: "FFF2E2"))
        .cornerRadius(28)
        .padding(.horizontal)
    }

    func flareImage(named name: String) -> Image {
        if UIImage(named: name) != nil {
            return Image(name)
        } else {
            return Image("defaultProfile")
        }
    }
}

