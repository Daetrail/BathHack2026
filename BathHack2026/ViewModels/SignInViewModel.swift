//
//  SignInViewModel.swift
//  BathHack2026
//
//  Handles sign-in form state and authentication via the API.
//

import SwiftUI

@Observable
class SignInViewModel {
    var navigateToList = false
    var userNameInput: String = ""
    var passwordInput: String = ""
    var showError: Bool = false
    var errorMessage: String = ""
    var isLoading: Bool = false

    /// Attempt to sign in with the entered credentials.
    /// On success, updates the global AppState to navigate to the home screen.
    func signIn(appState: AppState) async {
        // Basic client-side validation
        guard !userNameInput.isEmpty, !passwordInput.isEmpty else {
            errorMessage = "Please enter both username and password."
            showError = true
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await ServiceContainer.shared.authService.signIn(
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
