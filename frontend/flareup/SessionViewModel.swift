import Foundation
import Supabase

@MainActor
class SessionViewModel: ObservableObject {
    @Published var userID: String? = nil
    @Published var isAuthenticated: Bool = false

    func login(email: String, password: String) async {
        do {
            let session = try await SupabaseManager.shared.client.auth.signIn(
                email: email,
                password: password
            )
            let user = session.user
            self.userID = user.id.uuidString
            self.isAuthenticated = true
        } catch {
            print("Login failed: \(error.localizedDescription)")
        }
    }

    func logout() async {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
            self.userID = nil
            self.isAuthenticated = false
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
    
    func loadSession() async {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let user = session.user
            self.userID = user.id.uuidString
            self.isAuthenticated = true
            print("✅ Session restored for user: \(user.id)")
        } catch {
            print("Failed to load session: \(error.localizedDescription)")
        }
    }

}

