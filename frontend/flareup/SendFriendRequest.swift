import SwiftUI

struct SendFriendRequestView: View {
    @State private var username: String = ""

    var body: some View {
        ZStack {
            Color(hex: "F7941D").ignoresSafeArea() // Covers entire background including behind header
            VStack(spacing: 0) {
                    // Light orange block at the top (to mimic flareupHeader background)
                    Rectangle()
                        .fill(Color(hex: "FFF2E2"))
                        .frame(height: 150) // adjust height as needed
                        .offset(y:-100)
                    Spacer()
                }
            VStack(spacing: 24) {
                FlareupHeader()

                Text("Add by Username")
                    .font(.custom("Poppins-Bold", size: 35))
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    Text("Who would you like to add as a friend?")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.white)

                    TextField("abrilchuzz", text: $username)
                        .padding()
                        .background(Color(hex: "FFA74F"))
                        .cornerRadius(30)
                        .foregroundColor(.white)
                        .font(.custom("Poppins-Regular", size: 18))
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding(.horizontal)
                }

                Button(action: {
                    // Send request action
                }) {
                    Text("send friend request")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(Color(hex: "F7941D"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(30)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 32)
        }
    }
}
#Preview {
    SendFriendRequestView()
}
