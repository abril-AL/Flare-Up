import SwiftUI

struct ScreenTimeEntry: Codable {
    let duration: Int
    let date: String
    let category: String
}

struct ScreenTimeInputView: View {
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var selectedCategory = "Social Media"
    @State private var selectedDate = Date()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSubmitting = false
    @State private var retryCount = 0
    @State private var showReplaceConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @AppStorage("userId") private var userId: String = ""
    @AppStorage("authToken") private var authToken: String = ""

    let categories = ["Total"]
    let maxRetries = 3

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Duration")) {
                    HStack {
                        Picker("Hours", selection: $hours) {
                            ForEach(0..<24) { hour in Text("\(hour) hr").tag(hour) }
                        }.pickerStyle(MenuPickerStyle())

                        Picker("Minutes", selection: $minutes) {
                            ForEach(0..<60) { minute in Text("\(minute) min").tag(minute) }
                        }.pickerStyle(MenuPickerStyle())
                    }
                }

                Section(header: Text("Date")) {
                    DatePicker("Screentime Date", selection: $selectedDate, displayedComponents: .date)
                }

                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in Text(category) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section {
                    Button("Submit") {
                        Task { await checkAndSubmitScreenTime() }
                    }
                    .disabled(isSubmitting)
                }
            }
            .navigationTitle("Log Screen Time")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertMessage.contains("successfully") ? "Success" : "Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) { if alertMessage.contains("successfully") { dismiss() } }
                )
            }
            .confirmationDialog(
                "An entry for this date already exists. Replace it?",
                isPresented: $showReplaceConfirmation,
                titleVisibility: .visible
            ) {
                Button("Replace", role: .destructive) {
                    Task { await submitScreenTime(overwrite: true) }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func checkAndSubmitScreenTime() async {
        let dateString = ISO8601DateFormatter().string(from: selectedDate)
        guard let url = URL(string: "\(Config.backendURL)/screentime/\(userId)") else {
            handleError("Invalid check URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let existingEntries = try JSONDecoder().decode([ScreenTimeEntry].self, from: data)
            if existingEntries.contains(where: { $0.date.prefix(10) == dateString.prefix(10) }) {
                showReplaceConfirmation = true
                return
            } else {
                await submitScreenTime()
            }
        } catch {
            await submitScreenTime() // fallback to default submit
        }
    }

    private func submitScreenTime(overwrite: Bool = false) async {
        isSubmitting = true
        let totalMinutes = (hours * 60) + minutes
        let isoDate = ISO8601DateFormatter().string(from: selectedDate)
        let entry = ScreenTimeEntry(duration: totalMinutes, date: isoDate, category: selectedCategory)

        guard let url = URL(string: "\(Config.backendURL)/screentime") else {
            handleError("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue(authToken, forHTTPHeaderField: "token")

        do {
            let body = try JSONEncoder().encode(entry)
            request.httpBody = body

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let err = try? JSONDecoder().decode([String: String].self, from: data)
                handleError(err?["error"] ?? "Server error \(httpResponse.statusCode)")
            } else {
                handleSuccess()
            }
        } catch {
            handleError("Network error: \(error.localizedDescription)")
        }

        isSubmitting = false
    }

    private func handleSuccess() {
        alertMessage = "Screen time logged successfully!"
        hours = 0
        minutes = 0
        selectedCategory = "Social Media"
        retryCount = 0
        showAlert = true
    }

    private func handleError(_ message: String) {
        alertMessage = retryCount >= maxRetries ?
            "Failed after \(maxRetries) attempts: \(message)" : "Error: \(message)"
        isSubmitting = false
        showAlert = true
    }
}
