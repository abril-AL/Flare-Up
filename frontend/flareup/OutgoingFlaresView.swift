import SwiftUI

struct OutgoingFlaresView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var isNavigatingToSendFlare = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("outgoing flares")
                .font(.custom("Poppins-Bold", size: 28))
                .foregroundColor(Color(hex: "F25D29"))
                .padding(.top)

            NavigationLink(destination: SendFlareView(), isActive: $isNavigatingToSendFlare) {
                HStack {
                    Image("flare-white")
                        .resizable()
                        .frame(width: 24, height: 24)

                    Text("send a flare")
                        .font(.custom("Poppins-Regular", size: 28))
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color(hex: "F25D29"))
                .cornerRadius(40)
                .shadow(radius: 2)
            }

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(session.outgoingFlares) { flare in
                        VStack(alignment: .leading, spacing: 12) {
                            // Flare Note
                            if let note = flare.note, !note.isEmpty {
                                Text("“\(note)”")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.gray)
                                    .padding(10)
                                    .background(Color(hex: "E9E0D4"))
                                    .cornerRadius(16)
                            }

                            // Action Buttons
                            HStack(spacing: 12) {
                                Button("resolve") {
                                    Task {
                                        await session.deleteFlare(id: flare.id)
                                    }
                                }
                                .font(.custom("Poppins-Bold", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(Color(hex: "F25D29"))
                                .cornerRadius(30)

                                Button("edit") {
                                    // Add edit functionality here
                                }
                                .font(.custom("Poppins-Bold", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(hex: "77787B"))
                                .cornerRadius(30)
                            }

                            // Sent To Section
                            Text("sent to...")
                                .font(.custom("Poppins-Bold", size: 25))
                                .foregroundColor(Color(hex: "F25D29"))

                            HStack(spacing: 8) {
                                Image(flare.recipient.imageName)
                                    .resizable()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())

                                Text("@\(flare.recipient.username)")
                                    .font(.custom("Poppins-Regular", size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(hex: "FFF2E2"))
                        .cornerRadius(20)
                        .shadow(radius: 1)
                    }
                }
                .padding(.top)
            }

            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await session.loadOutgoingFlares()
            }
        }
    }
}

