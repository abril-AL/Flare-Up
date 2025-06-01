//
//  Untitled.swift
//  flareup
//
//  Created by Richelle Shim on 5/31/25.
//

import Foundation

struct VisionAPI {
    static let apiKey = "AIzaSyD6gX_ue72ZcclrpVdTzCeCzb56e6fO21c"
    static let endpoint = "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)"

    static func performOCR(base64Image: String) async throws -> String {
        let requestBody: [String: Any] = [
            "requests": [[
                "image": ["content": base64Image],
                "features": [["type": "TEXT_DETECTION"]]
            ]]
        ]

        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)

        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let responses = json["responses"] as? [[String: Any]],
           let fullTextAnnotation = responses.first?["fullTextAnnotation"] as? [String: Any],
           let text = fullTextAnnotation["text"] as? String {
            return text
        }

        throw NSError(domain: "VisionAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "No text found"])
    }
}
