import SwiftUI

struct SendFlareView: View {
    @State private var statusMessage = "locked in"
    @State private var note = ""
    @State private var selectedRecipients: Set<String> = []

    let recipients = [
        (name: "Abril", handle: "@abrillchuzz"),
        (name: "Dalton", handle: "@uwu420"),
        (name: "Eunice", handle: "@Nice_xD"),
        (name: "Hanger", handle: "@coat_hanger"),
        (name: "Ollie", handle: "@OlliePop"),
        (name: "Richelle", handle: "@greedyXOXO")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Send a Flare")
                    .font(.custom("Poppins-Bold", size: 28))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Edit your Status Message")
                        .foregroundColor(.white)
                        .font(.custom("Poppins-Regular", size: 14))

                    HStack {
                        Image(systemName: "wand.and.stars")
                        TextField("", text: $statusMessage)
                    }
                    .padding()
                    .background(Color(hex: "F9A34D"))
                    .cornerRadius(18)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a Note")
                        .foregroundColor(.white)
                        .font(.custom("Poppins-Regular", size: 14))

                    TextField("\"NEED TO LOCK IN\"", text: $note)
                        .padding()
                        .background(Color(hex: "FCD7A7"))
                        .cornerRadius(18)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Who do you want to Flare?")
                        .foregroundColor(.white)
                        .font(.custom("Poppins-Regular", size: 14))

                    ForEach(recipients, id: \.handle){ person in
                        HStack {
                            Text("\(person.name) (\(person.handle))")
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundColor(selectedRecipients.contains(person.handle) ? Color(hex: "F25D29") : .white)

                            Spacer()

                            Button(action: {
                                if selectedRecipients.contains(person.handle) {
                                    selectedRecipients.remove(person.handle)
                                } else {
                                    selectedRecipients.insert(person.handle)
                                }
                            }) {
                                Image("flare-white")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .opacity(selectedRecipients.contains(person.handle) ? 1.0 : 0.4)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                }

                Button(action: {
                    // Handle send logic
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
            }
            .padding()
        }
        .background(Color(hex: "F7941D").ignoresSafeArea())
    }
}

#Preview {
    SendFlareView()
}
