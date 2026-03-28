//
//  RegisterViewModel.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//
//  Handles registration form state and account creation via the API.
//

import SwiftUI

@Observable
class RegisterViewModel {
    var navigateToList = false
    var userNameInput: String = ""
    var passwordInput: String = ""
    var showError: Bool = false
    var errorMessage: String = ""
    var isLoading: Bool = false

    /// Attempt to register a new account with the entered credentials.
    /// On success, updates the global AppState to navigate to the home screen.
    func register(appState: AppState) async {
        // Basic client-side validation
        guard !userNameInput.isEmpty else {
            errorMessage = "Please enter a username."
            showError = true
            return
        }
        guard !passwordInput.isEmpty else {
            errorMessage = "Please enter a password."
            showError = true
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await ServiceContainer.shared.authService.signUp(
                username: userNameInput,
                password: passwordInput
            )
            // Store the username and mark as authenticated
            appState.username = userNameInput
            appState.authState = .authenticated
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            }
            showError = true
        } catch {
            errorMessage = "Unable to connect. Please check your internet connection."
            showError = true
        }
    }
}
