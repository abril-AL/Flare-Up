import SwiftUI

struct ScreenTimeInputView: View {
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var mostUsedApp: String = ""
    @State private var selectedDate = Date()
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
        @Environment(\.dismiss) private var dismiss
        @AppStorage("userId") private var userId: String = ""
        @AppStorage("authToken") private var authToken: String = ""

    var body: some View {
        ZStack {
            Color(hex: "FFECDD")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image("flareup") // Replace with your asset name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 60)
                    .padding(.top, 40)

                VStack(spacing: 8) {
                    Text("Drop Report")
                        .font(.custom("Poppins-Bold", size: 28))
                        .foregroundColor(Color(hex: "F25D29"))

                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(Color(hex: "F25D29"))
                }

                VStack(alignment: .leading, spacing: 20) {
                    Text("Enter your daily screentime")
                        .font(.custom("Poppins-Regular", size: 16))

                    HStack {
                        Picker("Hours", selection: $hours) {
                            ForEach(0..<24) { Text("\($0) hr").tag($0) }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)

                        Picker("Minutes", selection: $minutes) {
                            ForEach(0..<60) { Text("\($0) min").tag($0) }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }

                    Text("What was your most used app?")
                        .font(.custom("Poppins-Regular", size: 16))

                    TextField("e.g. TikTok", text: $mostUsedApp)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)

                Button(action: submit) {
                    Text("submit report")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "FFECDD"))
                        .foregroundColor(Color(hex: "F25D29"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "F25D29"), lineWidth: 2)
                        )
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                .disabled(isSubmitting)

                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Success"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func submit() {
        isSubmitting = true

        let totalMinutes = (hours * 60) + minutes
        let isoDate = ISO8601DateFormatter().string(from: selectedDate)
        let entry: [String: Any] = [
            "duration": totalMinutes,
            "date": isoDate,
            "category": mostUsedApp  // using 'category' to store most used app
        ]

        guard let url = URL(string: "\(Config.backendURL)/screentime") else {
            alertMessage = "Invalid backend URL."
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue(authToken, forHTTPHeaderField: "token")  // ← Add this

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: entry)

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    isSubmitting = false

                    if let error = error {
                        alertMessage = "Failed to submit: \(error.localizedDescription)"
                        showAlert = true
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse {
                        if !(200...299).contains(httpResponse.statusCode) {
                            alertMessage = "Error \(httpResponse.statusCode): Unauthorized. Please log in again."
                            showAlert = true
                            return
                        }
                    }

                    alertMessage = "Submitted successfully for \(formattedDate(selectedDate))!"
                    showAlert = true
                    hours = 0
                    minutes = 0
                    mostUsedApp = ""
                    dismiss()
                }
            }.resume()
        } catch {
            isSubmitting = false
            alertMessage = "Encoding error: \(error.localizedDescription)"
            showAlert = true
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
