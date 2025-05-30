import Foundation
import Supabase
import GoTrue
import PostgREST
import Realtime

enum SupabaseClient {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://lejqwwjzlpwxsdrohllq.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxlanF3d2p6bHB3eHNkcm9obGxxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4MTc3MTQsImV4cCI6MjA2MjM5MzcxNH0.vwVppZfEU9quJWlAS_j4JlRLVg3Uc_eaWs9cF43ACHk"
    )
}

// Extension to handle Supabase errors
extension Error {
    var supabaseError: String {
        switch self {
        case let error as SupabaseError:
            switch error {
            case .requestFailed(let message):
                return message
            case .serializationFailed:
                return "Failed to process data"
            case .unexpectedResponse:
                return "Unexpected response from server"
            }
        default:
            return localizedDescription
        }
    }
} 