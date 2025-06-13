import SwiftUI
import VisionKit
import Supabase
import Vision

struct OutgoingFlare: Identifiable, Decodable {
    let id: String
    let status: String
    let note: String?
    let created_at: String
    let recipient: Recipient

    struct Recipient: Decodable {
        let id: String
        let name: String
        let username: String
        let profile_picture: String?

        var imageName: String {
            profile_picture ?? "defaultProfile"
        }
    }
}

struct IncomingFlareResponse: Decodable {
    let flares: [IncomingFlare]
}

struct GroupModel: Identifiable, Decodable {
    let id: UUID
    let name: String
    let members: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case members
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.members = try container.decode([String].self, forKey: .members)
    }
}



struct ScreentimeEntry: Encodable {
    let user_id: String
    let date: String
    let total_minutes: Int
    let top_apps: [String: Int]
}

struct Friend: Identifiable, Decodable {
    let id: UUID
    let name: String
    let username: String
    let hours: Int
    let imageName: String
    var rank: Int = 0  // Added default value

    enum CodingKeys: String, CodingKey {
        case id, name, username, hours, imageName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        hours = try container.decodeIfPresent(Int.self, forKey: .hours) ?? 0
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName) ?? "defaultProfile"
    }

    init(id: UUID, name: String, username: String, hours: Int, imageName: String, rank: Int) {
        self.id = id
        self.name = name
        self.username = username
        self.hours = hours
        self.imageName = imageName
        self.rank = rank
    }
}




struct FriendRequest: Identifiable, Decodable {
    let id = UUID() // This is fine for UI identity
    let sender_id: String           // Add this!
    let name: String
    let username: String
    let imageName: String

    enum CodingKeys: String, CodingKey {
        case sender_id
        case name
        case username
        case imageName = "profile_picture"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.sender_id = try container.decode(String.self, forKey: .sender_id)
        
        let usernameRaw = try container.decode(String.self, forKey: .username)
        let cleanedUsername = usernameRaw.replacingOccurrences(of: "@", with: "")
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? cleanedUsername
        self.username = usernameRaw
        self.imageName = try container.decode(String.self, forKey: .imageName)
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
    @Published var outgoingFlares: [OutgoingFlare] = []
    @Published var incomingFlares: [IncomingFlare] = []
    @Published var groups: [GroupModel] = []


    @AppStorage("userId") private var storedUserId: String = ""
    @AppStorage("authToken") var authToken: String = ""

    var userId: String {
        storedUserId
    }

    private var currentSession: Session?

    init() {
        Task {
            await loadSession()
            
            if !storedUserId.isEmpty {
                await loadUserProfile()
            }
        }
    }
    
    @MainActor
    func fetchGroupDetails() async {
        guard !userId.isEmpty else {
            print("⚠️ No user ID")
            return
        }

        guard let url = URL(string: "http://localhost:4000/groups/user/\(userId)/details") else {
            print("❌ Invalid group details URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Group details JSON:\n\(jsonString)")
            }

            struct Response: Decodable {
                let groups: [GroupModel]
            }

            let decoded = try JSONDecoder().decode(Response.self, from: data)

            self.groups = decoded.groups
            print("✅ Loaded \(decoded.groups.count) groups")

        } catch {
            print("❌ Failed to fetch group details:", error.localizedDescription)
        }
    }

    
    @MainActor
    func loadIncomingFlares() async {
        guard !userId.isEmpty else {
            print("⚠️ Missing user ID")
            return
        }

        guard let url = URL(string: "http://localhost:4000/flares/incoming/\(userId)") else {
            print("❌ Invalid incoming flares URL")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                if let raw = String(data: data, encoding: .utf8) {
                    print("❌ Server error:", raw)
                }
                return
            }

            let decodedResponse = try JSONDecoder().decode(IncomingFlareResponse.self, from: data)
            self.incomingFlares = decodedResponse.flares
            print("✅ Fetched \(decodedResponse.flares.count) incoming flares")

        } catch {
            print("❌ Failed to load incoming flares:", error.localizedDescription)
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
            await fetchGroupDetails()
        } catch {
            await MainActor.run {
                self.isAuthenticated = false
                self.storedUserId = ""
                self.authToken = ""
            }
        }
    }
    
    struct OutgoingFlareResponse: Decodable {
        let flares: [OutgoingFlare]
    }

    @MainActor
    func loadOutgoingFlares() async {
        guard !userId.isEmpty else { return }

        guard let url = URL(string: "http://localhost:4000/flares/outgoing/\(userId)") else {
            print("Invalid outgoing flares URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Raw JSON:\n\(jsonString)")
            }

            let decoded = try JSONDecoder().decode(OutgoingFlareResponse.self, from: data)
            self.outgoingFlares = decoded.flares
            print("✅ Fetched \(decoded.flares.count) outgoing flares")

        } catch {
            print("❌ Failed to load outgoing flares:", error.localizedDescription)
        }
    }

    
    @MainActor
    func deleteFlare(id: String) async {
        guard let url = URL(string: "http://localhost:4000/flares/\(id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                self.outgoingFlares.removeAll { $0.id == id }
                print("✅ Deleted flare with id \(id)")
            } else {
                print("❌ Failed to delete flare")
            }
        } catch {
            print("❌ Error deleting flare: \(error.localizedDescription)")
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

            // Load friends and user profile after login
            await fetchFriends(for: session.user.id.uuidString)
            await loadUserProfile()
            await fetchGroupDetails()

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
            await loadUserProfile()
            await fetchGroupDetails()
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

    @MainActor
    func fetchFriends(for userId: String) async {
        guard let url = URL(string: "http://localhost:4000/friends/ranked/\(userId)") else {
            print("❌ Invalid URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            print("📦 Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")

            var decodedFriends = try JSONDecoder().decode([Friend].self, from: data)

            // Compute rank by sorting ascending by hours
            decodedFriends.sort { $0.hours < $1.hours }
            for (index, friend) in decodedFriends.enumerated() {
                decodedFriends[index] = Friend(
                    id: friend.id,
                    name: friend.name,
                    username: friend.username,
                    hours: friend.hours,
                    imageName: friend.imageName,
                    rank: index + 1
                )
            }

            self.friends = decodedFriends
            print("✅ Friends loaded with ranks")

        } catch {
            print("❌ Failed to fetch friends: \(error.localizedDescription)")
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
