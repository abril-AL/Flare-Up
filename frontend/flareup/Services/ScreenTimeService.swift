import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings

@MainActor
class ScreenTimeService: ObservableObject {
    static let shared = ScreenTimeService()
    private let center = DeviceActivityCenter()
    @Published var screenTime: TimeInterval = 0
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                
                let schedule = DeviceActivitySchedule(
                    intervalStart: DateComponents(hour: 0, minute: 0),
                    intervalEnd: DateComponents(hour: 23, minute: 59),
                    repeats: true
                )
                
                let activity = DeviceActivityName("daily")
                let eventName = DeviceActivityEvent.Name("screenTime")
                
                try center.startMonitoring(
                    activity,
                    during: schedule,
                    events: [eventName: schedule]
                )
            } catch {
                print("Failed to start monitoring: \(error)")
            }
        }
    }
    
    func updateScreenTime(_ time: TimeInterval) {
        screenTime = time
        Task {
            do {
                try await SupabaseClient.client
                    .database
                    .from("users")
                    .update(values: ["current_screen_time": Int(time)])
                    .eq("id", value: try await SupabaseClient.client.auth.session.user.id)
                    .execute()
            } catch {
                print("Failed to update screen time: \(error)")
            }
        }
    }
} 