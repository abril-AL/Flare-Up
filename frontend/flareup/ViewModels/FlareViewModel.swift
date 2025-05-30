import Foundation
import SwiftUI

@MainActor
class FlareViewModel: ObservableObject {
    @Published var activeFlares: [FlareService.Flare] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let flareService = FlareService.shared
    private let notificationService = NotificationService.shared
    
    init() {
        Task {
            await requestNotificationPermission()
            await loadActiveFlares()
        }
    }
    
    private func requestNotificationPermission() async {
        await notificationService.requestPermission()
    }
    
    func loadActiveFlares() async {
        isLoading = true
        do {
            activeFlares = try await flareService.getActiveFlares()
        } catch {
            errorMessage = error.supabaseError
        }
        isLoading = false
    }
    
    func sendFlare(message: String) {
        Task {
            do {
                let flare = try await flareService.sendFlare(message: message)
                await loadActiveFlares()
            } catch {
                errorMessage = error.supabaseError
            }
        }
    }
    
    func deactivateFlare(_ flare: FlareService.Flare) {
        Task {
            do {
                try await flareService.deactivateFlare(id: flare.id)
                await loadActiveFlares()
            } catch {
                errorMessage = error.supabaseError
            }
        }
    }
} 