import SwiftUI

struct OutgoingFlareCard: View {
    let flare: OutgoingFlare
    let onDelete: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Flare note
            if let note = flare.note, !note.isEmpty {
                Text("“\(note)”")
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(Color(hex: "E9E0D4"))
                    .cornerRadius(16)
            }

            // Action buttons
            HStack(spacing: 12) {
                Button("resolve") {
                    onDelete(flare.id)
                }
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Color(hex: "F25D29"))
                .cornerRadius(30)

                Button("edit") {
                    // Placeholder for future functionality
                }
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "77787B"))
                .cornerRadius(30)
            }

            // Recipient info
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

