import SwiftUI

struct ScreenTimeEntry: Codable {
    let duration: Int      // Total minutes (int8 in database)
    let date: String      // ISO8601 timestamp (timestamptz in database)
    let category: String  // text in database
}

struct ScreenTimeInputView: View {
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var selectedCategory = "Social Media"
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSubmitting = false
    @State private var retryCount = 0
    @Environment(\.dismiss) private var dismiss
    @AppStorage("userId") private var userId: String = ""
    @AppStorage("authToken") private var authToken: String = ""

    let categories = ["Social Media", "Entertainment", "Work", "Education", "Gaming"]
    let maxRetries = 3

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Duration")) {
                    HStack {
                        Picker("Hours", selection: $hours) {
                            ForEach(0..<24) { hour in
                                Text("\(hour) hr").tag(hour)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)

                        Picker("Minutes", selection: $minutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                    }
                }

                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section {
                    Button(action: {
                        Task {
                            await submitScreenTime()
                        }
                    }) {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Submit")
                        }
                    }
                    .disabled(isSubmitting)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(isSubmitting ? Color.gray : Color.blue)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Log Screen Time")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertMessage.contains("successfully") ? "Success" : "Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text(alertMessage.contains("successfully") ? "OK" : "Retry")) {
                        if alertMessage.contains("successfully") {
                            dismiss()
                        } else if retryCount < maxRetries {
                            Task {
                                await submitScreenTime()
                            }
                        }
                    }
                )
            }
        }
    }

    private func submitScreenTime() async {
        guard !isSubmitting else { return }
        
        // Validate user ID and auth token
        guard !userId.isEmpty else {
            handleError("User ID is missing. Please log in again.")
            return
        }
        
        guard !authToken.isEmpty else {
            handleError("Auth token is missing. Please log in again.")
            return
        }
        
        isSubmitting = true
        retryCount += 1
        
        // Convert hours and minutes to total minutes for the duration field
        let totalMinutes = (hours * 60) + minutes
        
        // Get current timestamp in ISO8601 format for the date field
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime]
        let timestamp = isoDateFormatter.string(from: Date())

        guard let url = URL(string: "\(Config.backendURL)/screentime") else {
            handleError("Invalid URL configuration: \(Config.backendURL)")
            return
        }
        let entry = ScreenTimeEntry(
            duration: totalMinutes,
            date: timestamp,
            category: selectedCategory
        )

        
        print("Submitting to URL:", url.absoluteString)
        print("Submitting entry:", entry)
        print("Using auth token:", authToken)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue(authToken, forHTTPHeaderField: "token")
        request.timeoutInterval = 30 // Set timeout to 30 seconds
        
        do {
            let jsonData = try JSONEncoder().encode(entry)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            print("JSON being sent:", jsonString)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code:", httpResponse.statusCode)
                print("Response headers:", httpResponse.allHeaderFields)
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response data:", responseString)
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    handleSuccess()
                } else {
                    if let errorData = try? JSONDecoder().decode([String: String].self, from: data),
                       let errorMessage = errorData["error"] {
                        handleError(errorMessage)
                    } else {
                        handleError("Server returned status code \(httpResponse.statusCode)")
                    }
                }
            }
        } catch {
            print("Network error details:", error)
            handleError("Network error: \(error.localizedDescription)")
        }
    }
    
    private func handleSuccess() {
        alertMessage = "Screen time logged successfully!"
        hours = 0
        minutes = 0
        selectedCategory = "Social Media"
        retryCount = 0
        isSubmitting = false
        showAlert = true
    }
    
    private func handleError(_ message: String) {
        alertMessage = retryCount >= maxRetries ? 
            "Failed after \(maxRetries) attempts: \(message)" :
            "Error: \(message)"
        isSubmitting = false
        showAlert = true
        print("Error occurred:", message)
    }
}
