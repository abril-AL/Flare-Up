//
//  SupabaseManager.swift
//  flareup
//
//  Created by Dalton Silverman on 5/30/25.
//

import Supabase
import Foundation

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://lejqwwjzlpwxsdrohllq.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxlanF3d2p6bHB3eHNkcm9obGxxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4MTc3MTQsImV4cCI6MjA2MjM5MzcxNH0.vwVppZfEU9quJWlAS_j4JlRLVg3Uc_eaWs9cF43ACHk"
        )
    }
}

