import Foundation

struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    var screenTimeGoal: Int?
    var currentScreenTime: Int?
    var profileImageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case screenTimeGoal = "screen_time_goal"
        case currentScreenTime = "current_screen_time"
        case profileImageURL = "profile_image_url"
    }
} 