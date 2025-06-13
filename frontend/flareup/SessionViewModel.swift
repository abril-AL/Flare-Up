import SwiftUI
import VisionKit
import Supabase
import Vision

struct ScreentimeEntry: Encodable {
    let user_id: String
    let date: String
    let total_minutes: Int
    let top_apps: [String: Int]
}

struct Friend: Identifiable, Decodable {
    let id: UUID
    let rank: Int
    let name: String
    let username: String // need for friends listing and adding friends / friend requests
    let hours: Int
    let imageName: String
}

struct FriendRequest: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let username: String
    let imageName: String

    enum CodingKeys: String, CodingKey {
        case name
        case username
        case imageName = "profile_picture"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let usernameRaw = try container.decode(String.self, forKey: .username)
        let cleanedUsername = usernameRaw.replacingOccurrences(of: "@", with: "")
        let name = try container.decodeIfPresent(String.self, forKey: .name) ?? cleanedUsername
        let imageName = try container.decode(String.self, forKey: .imageName)

        self.username = usernameRaw
        self.name = name
        self.imageName = imageName
    }
}


struct UserProfile: Decodable {
    let id: String
    let name: String?
    let username: String
    let profile_picture: String
    let goal_screen_time: Int
}


@MainActor
class SessionViewModel: ObservableObject {
    @Published var isUploading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var friends: [Friend] = []
    @Published var currentUser: UserProfile?
    @Published var incomingRequests: [FriendRequest] = []

    @AppStorage("userId") private var storedUserId: String = ""
    @AppStorage("authToken") var authToken: String = ""

    var userId: String {
        storedUserId
    }

    private var currentSession: Session?

    init() {
        Task {
            await loadSession()
        }
    }
    
    func loadFriendRequests() async {
        guard !userId.isEmpty else {
            print("⚠️ Missing user ID")
            return
        }

        guard let url = URL(string: "http://localhost:4000/friends/requests/\(userId)") else {
            print("❌ Invalid friend request URL")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let json = String(data: data, encoding: .utf8) {
                print("📦 Raw JSON:\n\(json)")
            }


            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                if let raw = String(data: data, encoding: .utf8) {
                    print("❌ Server error:", raw)
                }
                return
            }

            struct FriendRequestResponse: Decodable {
                let requests: [FriendRequest]
            }

            let decoded = try JSONDecoder().decode(FriendRequestResponse.self, from: data)

            await MainActor.run {
                self.incomingRequests = decoded.requests
                print("📥 Loaded \(decoded.requests.count) friend requests")
            }

        } catch {
            print("❌ Failed to load friend requests:", error.localizedDescription)
        }
    }

    
    func loadUserProfile() async {
        print("🔄 Starting to load user profile for userId:", userId)

        do {
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select("id, name, username, profile_picture, goal_screen_time")
                .eq("id", value: userId)
                .single()
                .execute()

            // 🔍 Log raw data
            let raw = response.data
            print("📦 Raw response.data (as Data):", raw)

            if let jsonString = String(data: raw, encoding: .utf8) {
                print("📄 Raw JSON string:\n\(jsonString)")
            }

            // ✅ Decode
            let user = try JSONDecoder().decode(UserProfile.self, from: raw)

            print("✅ Decoded user:")
            print("🆔 ID: \(user.id)")
            print("📛 Name: \(user.name)")
            print("👤 Username: \(user.username)")
            print("🖼️ Profile Picture: \(user.profile_picture)")
            print("🎯 Screen Time Goal: \(user.goal_screen_time) minutes")

            await MainActor.run {
                self.currentUser = user
                print("✅ Set currentUser in SessionViewModel")
            }

        } catch {
            print("❌ Failed to load user profile:", error.localizedDescription)
        }
    }







    func loadSession() async {
        do {
            let session = try await SupabaseManager.shared.getSession()
            await MainActor.run {
                self.isAuthenticated = true
                self.storedUserId = session.user.id.uuidString
                self.authToken = session.accessToken
            }
            await fetchFriends(for: session.user.id.uuidString)
        } catch {
            await MainActor.run {
                self.isAuthenticated = false
                self.storedUserId = ""
                self.authToken = ""
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        do {
            try await SupabaseManager.shared.signIn(email: email, password: password)
            let session = try await SupabaseManager.shared.getSession()
            await MainActor.run {
                self.isAuthenticated = true
                self.storedUserId = session.user.id.uuidString
                self.authToken = session.accessToken
            }
            await fetchFriends(for: session.user.id.uuidString)
            await loadUserProfile()
        } catch {
            await MainActor.run {
                self.isAuthenticated = false
                self.storedUserId = ""
                self.authToken = ""
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }

    func signUp(email: String, password: String) async throws {
        do {
            try await SupabaseManager.shared.signUp(email: email, password: password)
            let session = try await SupabaseManager.shared.getSession()
            await MainActor.run {
                self.isAuthenticated = true
                self.storedUserId = session.user.id.uuidString
                self.authToken = session.accessToken
            }
            await fetchFriends(for: session.user.id.uuidString)
        } catch {
            await MainActor.run {
                self.isAuthenticated = false
                self.storedUserId = ""
                self.authToken = ""
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }

    func signOut() async {
        do {
            try await SupabaseManager.shared.signOut()
            await MainActor.run {
                self.isAuthenticated = false
                self.currentSession = nil
                self.storedUserId = ""
                self.authToken = ""
                self.friends = []
            }
        } catch {
            print("Sign out error:", error.localizedDescription)
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
            print("📱 Friends List:")
            for friend in decoded {
                print("• \(friend.name) (@\(friend.username)) – \(friend.hours) hours")
            }
        } catch {
            print("Failed to fetch friends: \(error.localizedDescription)")
        }
    }

    func processImage(_ image: UIImage) async {
        guard let cgImage = image.cgImage else {
            errorMessage = "Invalid image"
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        do {
            try requestHandler.perform([request])
        } catch {
            errorMessage = "OCR failed: \(error.localizedDescription)"
            return
        }

        guard let results = request.results, !results.isEmpty else {
            errorMessage = "No text found in image"
            return
        }

        let text = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
        print("🔍 OCR Text:\n\(text)")

        // Basic screen time verification
        guard text.contains("Screen Time") || text.contains("Daily Average") else {
            errorMessage = "This does not appear to be a valid Screen Time screenshot."
            return
        }

        let totalMinutes = extractTotalMinutes(from: text)
        let topApps = extractTopApps(from: text)

        do {
            let session = try await SupabaseManager.shared.getSession()
            try await SupabaseManager.shared.ensureAuthenticated()

            let entry = ScreentimeEntry(
                user_id: session.user.id.uuidString,
                date: ISO8601DateFormatter().string(from: Date()),
                total_minutes: totalMinutes,
                top_apps: topApps
            )

            _ = try await SupabaseManager.shared.client
                .from("screentime")
                .insert(entry)
                .execute()

        } catch {
            errorMessage = "Failed to upload screentime: \(error.localizedDescription)"
        }
    }

    private func extractTotalMinutes(from text: String) -> Int {
        if let match = text.range(of: #"(\d+)h\s*(\d+)m"#, options: .regularExpression) {
            let parts = text[match].split(separator: " ")
            let hours = Int(parts.first?.dropLast() ?? "") ?? 0
            let minutes = Int(parts.last?.dropLast() ?? "") ?? 0
            return hours * 60 + minutes
        }
        return 0
    }

    private func extractTopApps(from text: String) -> [String: Int] {
        var results: [String: Int] = [:]
        let lines = text.components(separatedBy: "\n")
        for line in lines {
            if let match = line.range(of: #"([a-zA-Z]+).*\s(\d+)m"#, options: .regularExpression) {
                let parts = line[match].components(separatedBy: " ")
                if parts.count >= 2 {
                    let app = parts[0]
                    let minutes = Int(parts.last?.dropLast() ?? "") ?? 0
                    results[app] = minutes
                }
            }
        }
        return results
    }
}
