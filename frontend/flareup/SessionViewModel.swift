import Foundation
import Supabase

struct Friend: Identifiable, Decodable {
    let id: UUID
    let rank: Int
    let name: String
    let hours: Int
    let imageName: String
}

@MainActor
class SessionViewModel: ObservableObject {
    @Published var userID: String? = nil
    @Published var isAuthenticated: Bool = false
    @Published var friends: [Friend] = []

    func login(email: String, password: String) async {
        do {
            let session = try await SupabaseManager.shared.client.auth.signIn(
                email: email,
                password: password
            )
            self.userID = session.user.id.uuidString
            self.isAuthenticated = true
            await fetchFriends(for: session.user.id.uuidString)
        } catch {
            print("Login failed: \(error.localizedDescription)")
        }
    }

    func logout() async {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
            self.userID = nil
            self.isAuthenticated = false
            self.friends = []
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }

    func loadSession() async {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            self.userID = session.user.id.uuidString
            self.isAuthenticated = true
            await fetchFriends(for: session.user.id.uuidString)
        } catch {
            print("No active session: \(error.localizedDescription)")
        }
    }

    private func fetchFriends(for userID: String) async {
        guard let url = URL(string: "http://localhost:4000/friends/ranked/\(userID)") else {
            print("Invalid friends URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([Friend].self, from: data)
            self.friends = decoded
        } catch {
            print("Failed to fetch friends: \(error.localizedDescription)")
        }
    }
}

