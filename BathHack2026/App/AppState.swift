//
//  AppState.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation

/// Global app state that tracks authentication status.
/// Passed through the SwiftUI environment so any view can read/update auth state.
@MainActor
@Observable
final class AppState {
    enum AuthState {
        case unknown          // App just launched, checking saved session
        case authenticated    // User has a valid session
        case unauthenticated  // Token expired or invalid
        case neverLoggedIn    // No saved token — first-time user
    }

    var authState: AuthState = .unknown
    var username: String?

    /// Check for a saved session on app launch.
    /// Restores the token from keychain and verifies it with the server.
    func checkAuth() async {
        let services = ServiceContainer.shared
        services.authService.setTokenFromKeychain()

        // No saved token means the user has never logged in
        guard services.networkService.token != nil else {
            authState = .neverLoggedIn
            return
        }

        do {
            if let restoredUsername = try await services.authService.isAuthenticated() {
                username = restoredUsername
                authState = .authenticated
            } else {
                authState = .unauthenticated
            }
        } catch {
            // Network error — be optimistic and let the user in.
            // Individual API calls will handle auth failures gracefully.
            authState = .authenticated
        }
    }

    /// Sign the user out by clearing tokens and resetting state
    func signOut() {
        ServiceContainer.shared.authService.signOut()
        username = nil
        authState = .unauthenticated
    }
}
