import Foundation
import Combine

class CountdownViewModel: ObservableObject {
    @Published var days: String = "00"
    @Published var hours: String = "00"
    @Published var minutes: String = "00"
    @Published var seconds: String = "00"
    
    private var timer: Timer?

    init() {
        startCountdown()
    }

    private func startCountdown() {
        updateCountdown()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateCountdown()
        }
    }

    private func updateCountdown() {
        let now = Date()
        let calendar = Calendar.current
        var nextSunday = calendar.nextDate(after: now, matching: DateComponents(weekday: 1), matchingPolicy: .nextTime)!
        nextSunday = calendar.startOfDay(for: nextSunday)
        
        let remaining = nextSunday.timeIntervalSince(now)
        let d = Int(remaining) / 86400
        let h = (Int(remaining) % 86400) / 3600
        let m = (Int(remaining) % 3600) / 60
        let s = Int(remaining) % 60

        days = String(format: "%02d", d)
        hours = String(format: "%02d", h)
        minutes = String(format: "%02d", m)
        seconds = String(format: "%02d", s)
    }
}
