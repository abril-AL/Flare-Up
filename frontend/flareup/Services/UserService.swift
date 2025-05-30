import Foundation

actor UserService {
    static let shared = UserService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    func getCurrentUser() async throws -> User {
        return try await networkManager.request("/users/me")
    }
    
    func updateUser(_ user: User) async throws -> User {
        return try await networkManager.post("/users/update", body: user)
    }
    
    func updateScreenTime(_ screenTime: Int) async throws -> User {
        struct ScreenTimeUpdate: Codable {
            let currentScreenTime: Int
        }
        return try await networkManager.post("/users/screen-time", 
            body: ScreenTimeUpdate(currentScreenTime: screenTime))
    }
    
    func getFriends() async throws -> [User] {
        return try await networkManager.request("/friends")
    }
    
    func addFriend(userId: String) async throws -> Bool {
        struct FriendRequest: Codable {
            let friendId: String
        }
        let response: [String: Bool] = try await networkManager.post("/friends/add",
            body: FriendRequest(friendId: userId))
        return response["success"] ?? false
    }
} 