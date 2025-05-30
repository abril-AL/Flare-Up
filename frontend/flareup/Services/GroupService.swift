import Foundation
import Supabase

actor GroupService {
    static let shared = GroupService()
    private let client = SupabaseClient.client
    
    private init() {}
    
    func createGroup(name: String, description: String? = nil,
                    weeklyWager: Int? = nil, weeklyGoal: Int? = nil) async throws -> Group {
        let data: [String: Any] = [
            "name": name,
            "description": description as Any,
            "weekly_wager": weeklyWager as Any,
            "weekly_goal": weeklyGoal as Any,
            "creator_id": try await client.auth.session.user.id
        ]
        
        let response = try await client
            .database
            .from("groups")
            .insert(values: data)
            .single()
            .execute()
        
        return try JSONDecoder().decode(Group.self, from: response.data)
    }
    
    func getGroups() async throws -> [Group] {
        let response = try await client
            .database
            .from("groups")
            .select("*, members:group_members(user:users(*))")
            .execute()
        
        return try JSONDecoder().decode([Group].self, from: response.data)
    }
    
    func getGroupById(groupId: String) async throws -> Group {
        let response = try await client
            .database
            .from("groups")
            .select("*, members:group_members(user:users(*))")
            .eq("id", value: groupId)
            .single()
            .execute()
        
        return try JSONDecoder().decode(Group.self, from: response.data)
    }
    
    func addMemberToGroup(groupId: String, userId: String) async throws -> Bool {
        let data = ["group_id": groupId, "user_id": userId]
        
        _ = try await client
            .database
            .from("group_members")
            .insert(values: data)
            .execute()
        
        return true
    }
    
    func updateGroupGoals(groupId: String, weeklyWager: Int?, weeklyGoal: Int?) async throws -> Group {
        var data: [String: Any] = [:]
        if let weeklyWager = weeklyWager {
            data["weekly_wager"] = weeklyWager
        }
        if let weeklyGoal = weeklyGoal {
            data["weekly_goal"] = weeklyGoal
        }
        
        let response = try await client
            .database
            .from("groups")
            .update(values: data)
            .eq("id", value: groupId)
            .single()
            .execute()
        
        return try JSONDecoder().decode(Group.self, from: response.data)
    }
} 