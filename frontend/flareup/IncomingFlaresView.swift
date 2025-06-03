import SwiftUI

struct IncomingFlaresView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Incoming Flares")
                .font(.custom("Poppins-Bold", size: 28))
                .foregroundColor(Color(hex: "F25D29"))
                .padding(.top)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<5) { index in
                        HStack(spacing: 12) {
                            Image("defaultProfile") // Replace with actual user image
                                .resizable()
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text("User \(index + 1)")
                                    .font(.custom("Poppins-Bold", size: 16))
                                Text("sent you a flare")
                                    .font(.custom("Poppins-Regular", size: 14))
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Text("2h ago")
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(hex: "FFF2E2"))
                        .cornerRadius(16)
                        .shadow(radius: 1)
                    }
                }
                .padding(.bottom)
            }
        }
        .padding(.horizontal)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    IncomingFlaresView()
}
