import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    private var currentSession: Session?

    private init() {
        func getPlistValue(forKey key: String) -> String {
            guard let path = Bundle.main.path(forResource: "SupabaseConfig", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path),
                  let value = dict[key] as? String else {
                fatalError("Missing key '\(key)' in SupabaseConfig.plist")
            }
            return value
        }

        
        let supabaseURL = URL(string: getPlistValue(forKey: "SUPABASE_URL"))!
        let supabaseKey = getPlistValue(forKey: "SUPABASE_ANON_KEY")

        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)

    }
    
    func getSession() async throws -> Session {
        if let session = currentSession {
            return session
        }
        let session = try await client.auth.session
        currentSession = session
        print("Auth UID:", session.user.id)
        return session
    }
    
    func getAccessToken() async throws -> String {
        let session = try await getSession()
        return session.accessToken
    }
    
    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        currentSession = session
        print("Signed in with access token:", session.accessToken)
        
        try await client.auth.setSession(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
    }

    func signUp(email: String, password: String) async throws {
        let response = try await client.auth.signUp(email: email, password: password)

        guard let session = response.session else {
            print("Signed up but session is nil (email verification required?)")
            return
        }

        currentSession = session
        print("Signed up with session:", session.accessToken)

        try await client.auth.setSession(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
    }
    func signOut() async throws {
    try await client.auth.signOut()
    currentSession = nil
    print("Signed out from Supabase")
}

    
    func createAuthHeaders() async throws -> [String: String] {
        let session = try await getSession()
        return [
            "Authorization": "Bearer \(session.accessToken)",
            "Content-Type": "application/json"
        ]
    }
    
    func ensureAuthenticated() async throws {
        let session = try await getSession()
        try await client.auth.setSession(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
    }
}
