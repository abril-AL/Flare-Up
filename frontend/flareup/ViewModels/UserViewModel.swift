import Foundation
import SwiftUI

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var friends: [User] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let userService = UserService.shared
    
    func loadCurrentUser() {
        Task {
            isLoading = true
            do {
                currentUser = try await userService.getCurrentUser()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func updateScreenTime(_ screenTime: Int) {
        Task {
            do {
                currentUser = try await userService.updateScreenTime(screenTime)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func loadFriends() {
        Task {
            isLoading = true
            do {
                friends = try await userService.getFriends()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func addFriend(userId: String) {
        Task {
            do {
                if try await userService.addFriend(userId: userId) {
                    await loadFriends()
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
} 