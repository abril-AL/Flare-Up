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
                    Image("flare-white") // or your flare icon
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

            VStack(alignment: .leading, spacing: 12) {
                Text("“Someone please come to Powell and study with me”")
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(Color(hex: "E9E0D4"))
                    .cornerRadius(16)

                HStack(spacing: 12) {
                    Button("resolve") {
                        // action - delete flare ?
                    }
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 8)
                    .background(Color(hex: "F25D29"))
                    .cornerRadius(30)

                    Button("edit") {
                        // action -  idk ill figure it out later
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
                    Image("abrilPic")
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
