import SwiftUI

struct SendFlareView: View {
    @State private var statusMessage = "locked in"
    @State private var note = ""
    @State private var selectedRecipients: Set<String> = []
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CountdownViewModel()
    
    let recipients = [
        (name: "Abril", handle: "@abrillchuzz"),
        (name: "Dalton", handle: "@uwu420"),
        (name: "Eunice", handle: "@Nice_xD"),
        (name: "Hanger", handle: "@coat_hanger"),
        (name: "Ollie", handle: "@OlliePop"),
        (name: "Richelle", handle: "@greedyXOXO")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            FlareupHeader {}
            
            // Countdown bar under header
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
                VStack(alignment: .leading, spacing: 8) {
                    Text("Edit your Status Message")
                        .foregroundColor(.white)
                        .font(.custom("Poppins-Regula", size: 22))
                    
                    HStack {
                        Image(systemName: "wand.and.stars")
                        TextField("", text: $statusMessage)
                            .foregroundColor(.white)
                            .font(.custom("Poppins-Regula", size: 20))
                    }
                    .padding()
                    .background(Color(hex: "FFB55F"))
                    .cornerRadius(30)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a Note")
                        .foregroundColor(.white)
                        .font(.custom("Poppins-Regular", size: 22))
                    
                    TextField("\"NEED TO LOCK IN\"", text: $note)
                        .padding()
                        .background(Color(hex: "FFB55F"))
                        .cornerRadius(30)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Who do you want to Flare?")
                        .foregroundColor(.white)
                        .font(.custom("Poppins-Regular", size: 20))
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(recipients, id: \.handle) { person in
                                HStack {
                                    Text("\(person.name) (\(person.handle))")
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(selectedRecipients.contains(person.handle) ? Color(hex: "F67653") : .white)

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
                                            .frame(width: 30, height: 30)
                                            .opacity(selectedRecipients.contains(person.handle) ? 1.0 : 0.4)
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
                    .frame(maxWidth: .infinity)
                    
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
}
