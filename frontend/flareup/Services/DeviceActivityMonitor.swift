import Foundation
import DeviceActivity
import FamilyControls

class DeviceActivityMonitor: DeviceActivityMonitor {
    let screenTimeService = ScreenTimeService.shared
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // Reset screen time at the start of a new interval
        screenTimeService.updateScreenTime(0)
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // Final update at the end of the interval
        updateScreenTime()
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        // Update screen time when threshold is reached
        updateScreenTime()
    }
    
    private func updateScreenTime() {
        Task {
            if let schedule = try? await ManagedSettings.shared.shield.schedule {
                let totalTime = schedule.totalTime
                await screenTimeService.updateScreenTime(totalTime)
            }
        }
    }
} 