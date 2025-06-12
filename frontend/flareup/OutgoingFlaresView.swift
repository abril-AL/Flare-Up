import SwiftUI

struct OutgoingFlaresView: View {
    @EnvironmentObject var flareStore: FlareStore

    let handleToImage: [String: String] = [
        "@abrillchuzz": "abrilPic",
        "@uwu420": "daltonPic",
        "@Nice_xD": "eunicePic",
        "@coat_hanger": "hangerPic",
        "@OlliePop": "olliePic",
        "@greedyXOXO": "richellePic"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("outgoing flares")
                .font(.custom("Poppins-Bold", size: 28))
                .foregroundColor(Color(hex: "F25D29"))
                .padding(.top)

            NavigationLink(destination: SendFlareView()) {
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

            ForEach(flareStore.flares) { flare in
                VStack(alignment: .leading, spacing: 12) {
                    Text("“\(flare.note)”")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.gray)
                        .padding(10)
                        .background(Color(hex: "E9E0D4"))
                        .cornerRadius(16)

                    HStack(spacing: 12) {
                        Button("resolve") {
                            if let index = flareStore.flares.firstIndex(where: { $0.id == flare.id }) {
                                flareStore.flares.remove(at: index)
                            }
                        }
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color(hex: "F25D29"))
                        .cornerRadius(30)

                        Button("edit") {
                            // Placeholder for edit functionality
                        }
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "77787B"))
                        .cornerRadius(30)
                    }

                    Text("sent to...")
                        .font(.custom("Poppins-Bold", size: 25))
                        .foregroundColor(Color(hex: "F25D29"))

                    HStack(spacing: 8) {
                        ForEach(flare.recipients, id: \.self) { recipient in
                            if let imageName = handleToImage[recipient] {
                                Image(imageName)
                                    .resizable()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                            }
                        }

                        Text(flare.recipients.joined(separator: ", "))
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(hex: "FFF2E2"))
                .cornerRadius(20)
                .shadow(radius: 1)
            }

            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    OutgoingFlaresView().environmentObject(FlareStore())
}
