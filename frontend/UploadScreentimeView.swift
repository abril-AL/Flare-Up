//
//  UploadScreentimeView.swift
//  flareup
//
//  Created by Richelle Shim on 5/31/25.
//


import SwiftUI
import PhotosUI

struct UploadScreentimeView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var image: UIImage?
    @StateObject private var viewModel = SessionViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Upload Your Screen Time")
                .font(.title)
                .bold()

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }

            PhotosPicker("Select Screenshot", selection: $selectedItem, matching: .images)
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            image = uiImage
                            await viewModel.processImage(uiImage)
                        }
                    }
                }

            if viewModel.isUploading {
                ProgressView("Uploading...")
            }

            if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }
        }
        .padding()
    }
}
