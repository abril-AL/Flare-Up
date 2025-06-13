import SwiftUI

struct SendFlareView: View {
    @EnvironmentObject var session: SessionViewModel
    @EnvironmentObject var flareStore: FlareStore
    @StateObject private var viewModel = CountdownViewModel()
    
    @State private var statusMessage = "locked in"
    @State private var note = ""
    @State private var selectedRecipientIds: Set<UUID> = []
    @State private var navigateToFocus = false
    @Environment(\.dismiss) var dismiss

    // MARK: - Send Flare to Backend
    func sendFlare(from senderId: String, to recipientId: String, status: String, note: String?) async {
        guard let url = URL(string: "http://localhost:4000/flares/") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "sender_id": senderId,
            "recipient_id": recipientId,
            "status": status,
            "note": note ?? ""
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                print("❌ Failed to send flare:", String(data: data, encoding: .utf8) ?? "Unknown error")
            } else {
                print("✅ Flare sent to \(recipientId)")
            }
        } catch {
            print("❌ Error sending flare:", error.localizedDescription)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            FlareupHeader {}

            // Drop Countdown
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

            // Title Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
                Text("Send a Flare")
                    .font(.custom("Poppins-Bold", size: 32))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color(hex: "F7941D"))

            VStack(alignment: .leading, spacing: 12) {
                // Status Message Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Edit your Status Message")
                        .foregroundColor(.white)
                        .font(.custom("Poppins-Regular", size: 22))

                    HStack {
                        Image(systemName: "wand.and.stars")
                        TextField("", text: $statusMessage)
                            .foregroundColor(.white)
                            .font(.custom("Poppins-Regular", size: 20))
                    }
                    .padding()
                    .background(Color(hex: "FFB55F"))
                    .cornerRadius(30)
                }

                // Optional Note
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a Note")
                        .foregroundColor(.white)
                        .font(.custom("Poppins-Regular", size: 22))

                    TextField("\"NEED TO LOCK IN\"", text: $note)
                        .padding()
                        .background(Color(hex: "FFB55F"))
                        .cornerRadius(30)
                }

                // Friends Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Who do you want to Flare?")
                        .foregroundColor(.white)
                        .font(.custom("Poppins-Regular", size: 20))

                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(session.friends) { friend in
                                HStack {
                                    Text("\(friend.name) (@\(friend.username))")
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(
                                            selectedRecipientIds.contains(friend.id)
                                            ? Color(hex: "F67653")
                                            : .white
                                        )

                                    Spacer()

                                    Button(action: {
                                        if selectedRecipientIds.contains(friend.id) {
                                            selectedRecipientIds.remove(friend.id)
                                        } else {
                                            selectedRecipientIds.insert(friend.id)
                                        }
                                    }) {
                                        Image("flare-white")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .opacity(selectedRecipientIds.contains(friend.id) ? 1.0 : 0.4)
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(40)
                    }

                    // Submit Flare Button
                    Button(action: {
                        Task {
                            let senderId = session.userId
                            for recipientId in selectedRecipientIds {
                                await sendFlare(
                                    from: senderId,
                                    to: recipientId.uuidString,
                                    status: statusMessage,
                                    note: note.isEmpty ? nil : note
                                )
                            }
                            
                            await session.loadOutgoingFlares()
                            navigateToFocus = true
                        }
                    }) {
                        Text("send flares!")
                            .font(.custom("Poppins-Bold", size: 18))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color(hex: "F25D29"))
                            .cornerRadius(20)
                    }
                    .padding(.top)

                    NavigationLink(destination: FocusView(), isActive: $navigateToFocus) {
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "F7941D"))
            }
            .padding()
            .background(Color(hex: "F7941D").ignoresSafeArea())
        }
        .background(Color(hex: "F7941D").ignoresSafeArea())
    }
}

#Preview {
    SendFlareView()
        .environmentObject(SessionViewModel())
        .environmentObject(FlareStore())
}

