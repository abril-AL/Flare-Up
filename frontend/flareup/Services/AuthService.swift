import Foundation
import Supabase

actor AuthService {
    static let shared = AuthService()
    private let client = SupabaseClient.client
    
    private init() {}
    
    func signIn(email: String, password: String) async throws -> User {
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )
        return try await fetchUser(userId: session.user.id)
    }
    
    func signUp(email: String, password: String, username: String) async throws -> User {
        let session = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["username": username]
        )
        return try await fetchUser(userId: session.user.id)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    private func fetchUser(userId: String) async throws -> User {
        let response = try await client
            .database
            .from("users")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
        
        return try JSONDecoder().decode(User.self, from: response.data)
    }
    
    func getCurrentSession() async throws -> Session? {
        return try await client.auth.session
    }
} 