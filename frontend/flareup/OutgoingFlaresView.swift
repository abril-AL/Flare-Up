import SwiftUI

struct OutgoingFlaresView: View {
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
                        .font(.custom("Poppins-Bold", size: 18))
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "F25D29"))
                .cornerRadius(32)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("\"Someone please come to Powell and study with me\"")
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color(hex: "E9E0D4"))
                    .cornerRadius(12)

                HStack {
                    Button("resolve") {
                        // resolve action
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "F25D29"))
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Button("edit") {
                        // edit action
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "77787B"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                Text("sent to...")
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(Color(hex: "F25D29"))

                HStack(spacing: 8) {
                    Image("abrilProfile")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                    Text("Abril, Ollie, + 1 others")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(hex: "FFF2E2"))
            .cornerRadius(20)
            .shadow(radius: 1)

            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    OutgoingFlaresView()
}
