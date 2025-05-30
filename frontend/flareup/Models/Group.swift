import Foundation

struct Group: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let creatorId: String
    var members: [User]
    var weeklyWager: Int?
    var weeklyGoal: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case creatorId = "creator_id"
        case members
        case weeklyWager = "weekly_wager"
        case weeklyGoal = "weekly_goal"
    }
} 