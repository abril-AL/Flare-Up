import Foundation
import SwiftUI
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let authService = AuthService.shared
    private let userViewModel: UserViewModel
    
    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
        Task {
            await checkCurrentSession()
        }
    }
    
    func signIn(email: String, password: String) {
        Task {
            isLoading = true
            do {
                let user = try await authService.signIn(email: email, password: password)
                userViewModel.currentUser = user
                isAuthenticated = true
            } catch {
                errorMessage = error.supabaseError
            }
            isLoading = false
        }
    }
    
    func signUp(email: String, password: String, username: String) {
        Task {
            isLoading = true
            do {
                let user = try await authService.signUp(email: email, password: password, username: username)
                userViewModel.currentUser = user
                isAuthenticated = true
            } catch {
                errorMessage = error.supabaseError
            }
            isLoading = false
        }
    }
    
    func signOut() {
        Task {
            do {
                try await authService.signOut()
                userViewModel.currentUser = nil
                isAuthenticated = false
            } catch {
                errorMessage = error.supabaseError
            }
        }
    }
    
    private func checkCurrentSession() async {
        do {
            if let session = try await authService.getCurrentSession() {
                let user = try await authService.fetchUser(userId: session.user.id)
                userViewModel.currentUser = user
                isAuthenticated = true
            }
        } catch {
            errorMessage = error.supabaseError
        }
    }
} 