import SwiftUI

struct IncomingFlare: Identifiable, Decodable {
    let id: UUID
    let sender_id: String
    let sender_name: String
    let sender_username: String
    let sender_image: String
    let status: String
    let note: String?

    enum CodingKeys: String, CodingKey {
        case id, sender_id, sender_name, sender_username, sender_image, status, note
    }
}

struct IncomingFlaresView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var flares: [IncomingFlare] = []
    @StateObject private var countdown = CountdownViewModel()

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

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(flares) { flare in
                        HStack(alignment: .center, spacing: 12) {
                            flareImage(named: flare.sender_image)
                                .resizable()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(flare.sender_name)
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

    func flareImage(named name: String) -> Image {
        if UIImage(named: name) != nil {
            return Image(name)
        } else {
            return Image("defaultProfile")
        }
    }
}

