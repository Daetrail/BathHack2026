//
//  AuthService.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation

/// Response structure from the /sign-in, /sign-up, and /me endpoints
struct AuthResponse: Codable {
    let success: Bool
    let token: String?
    let message: String?
    let username: String?
}

/// Handles user authentication: sign up, sign in, session verification, and sign out.
final class AuthService {
    private let networkService: NetworkService
    private let userTokenKeychainService = "user_token"

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    /// Register a new user account and store the returned JWT token
    func signUp(username: String, password: String) async throws {
        let data = try await networkService.post("/sign-up", [
            "username": username,
            "password": password
        ])

        let response = try parseCodable(type: AuthResponse.self, from: data)

        guard response.success, let token = response.token else {
            throw APIError.serverError(message: response.message ?? "Sign up failed")
        }

        // Save token to keychain for persistent sessions
        try? KeychainHelper.standard.save(token, service: userTokenKeychainService)
        networkService.token = token
    }

    /// Sign in with existing credentials and store the returned JWT token
    func signIn(username: String, password: String) async throws {
        let data = try await networkService.post("/sign-in", [
            "username": username,
            "password": password
        ])

        let response = try parseCodable(type: AuthResponse.self, from: data)

        guard response.success, let token = response.token else {
            throw APIError.serverError(message: response.message ?? "Sign in failed")
        }

        // Save token to keychain for persistent sessions
        try? KeychainHelper.standard.save(token, service: userTokenKeychainService)
        networkService.token = token
    }

    /// Verify whether the current token is still valid with the server.
    /// The token is sent via the Authorization header (set by NetworkService).
    func isAuthenticated() async throws -> Bool {
        guard networkService.token != nil else {
            return false
        }

        // /me is a GET endpoint that checks the Bearer token in the header
        let data = try await networkService.get("/me")
        let response = try parseCodable(type: AuthResponse.self, from: data)

        return response.success
    }

    /// Restore the saved token from keychain into the network service.
    /// Call this on app launch to resume a previous session.
    func setTokenFromKeychain() {
        guard let token = try? KeychainHelper.standard.read(
            service: userTokenKeychainService,
            type: String.self
        ) else {
            return
        }

        networkService.token = token
    }

    /// Sign out by clearing the token from memory and keychain
    func signOut() {
        networkService.token = nil
        KeychainHelper.standard.delete(service: userTokenKeychainService)
    }
}
