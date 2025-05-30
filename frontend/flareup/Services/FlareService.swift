import Foundation
import Supabase

actor FlareService {
    static let shared = FlareService()
    private let client = SupabaseClient.client
    private let notificationService = NotificationService.shared
    
    private init() {
        setupRealtimeSubscription()
    }
    
    struct Flare: Codable, Identifiable {
        let id: String
        let senderId: String
        let message: String
        let createdAt: Date
        let isActive: Bool
        
        enum CodingKeys: String, CodingKey {
            case id
            case senderId = "sender_id"
            case message
            case createdAt = "created_at"
            case isActive = "is_active"
        }
    }
    
    private func setupRealtimeSubscription() {
        Task {
            do {
                try await client.realtime.connect()
                
                let channel = try await client.realtime
                    .channel("public:flares")
                    .on(.insert) { [weak self] payload in
                        guard let self = self,
                              let flare = try? JSONDecoder().decode(Flare.self, from: payload.data) else {
                            return
                        }
                        
                        Task {
                            let sender = try await self.getUser(id: flare.senderId)
                            await notificationService.sendFlareNotification(
                                from: sender,
                                message: flare.message
                            )
                        }
                    }
                    .subscribe()
                
                print("Subscribed to flares channel")
            } catch {
                print("Failed to setup realtime subscription: \(error)")
            }
        }
    }
    
    func sendFlare(message: String) async throws -> Flare {
        let userId = try await client.auth.session.user.id
        
        let data: [String: Any] = [
            "sender_id": userId,
            "message": message,
            "is_active": true
        ]
        
        let response = try await client
            .database
            .from("flares")
            .insert(values: data)
            .single()
            .execute()
        
        return try JSONDecoder().decode(Flare.self, from: response.data)
    }
    
    func getActiveFlares() async throws -> [Flare] {
        let response = try await client
            .database
            .from("flares")
            .select()
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
            .execute()
        
        return try JSONDecoder().decode([Flare].self, from: response.data)
    }
    
    private func getUser(id: String) async throws -> User {
        let response = try await client
            .database
            .from("users")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
        
        return try JSONDecoder().decode(User.self, from: response.data)
    }
    
    func deactivateFlare(id: String) async throws {
        try await client
            .database
            .from("flares")
            .update(values: ["is_active": false])
            .eq("id", value: id)
            .execute()
    }
} 