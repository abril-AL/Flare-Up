//import SwiftUI
//import PhotosUI
//
//struct ScreenTimeOCRView: View {
//    @State private var selectedItem: PhotosPickerItem? = nil
//    @State private var extractedText: String = ""
//    @State private var screenTimeEntries: [ScreenTimeEntry] = []
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                PhotosPicker("Upload Screenshot", selection: $selectedItem, matching: .images)
//                    .buttonStyle(.borderedProminent)
//
//                if isLoading {
//                    ProgressView("Analyzing...")
//                }
//
//                if !screenTimeEntries.isEmpty {
//                    List(screenTimeEntries) { entry in
//                        HStack {
//                            Text(entry.app)
//                            Spacer()
//                            Text("\(entry.minutes) min")
//                        }
//                    }
//                } else if let error = errorMessage {
//                    Text("Error: \(error)")
//                        .foregroundColor(.red)
//                }
//
//                Spacer()
//            }
//            .padding()
//            .navigationTitle("Screen Time OCR")
//            .onChange(of: selectedItem) { newItem in
//                Task {
//                    guard let item = newItem,
//                          let data = try? await item.loadTransferable(type: Data.self) else { return }
//
//                    isLoading = true
//                    errorMessage = nil
//                    do {
//                        let base64Image = data.base64EncodedString()
//                        let text = try await VisionAPI.performOCR(base64Image: base64Image)
//                        self.extractedText = text
//                        self.screenTimeEntries = ScreenTimeParser.parse(text: text)
//                    } catch {
//                        errorMessage = error.localizedDescription
//                    }
//                    isLoading = false
//                }
//            }
//        }
//    }
//}
