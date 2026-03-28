//
//  AuthService.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation

struct AuthResponse: Codable {
    let success: Bool
    let token: String?
    let message: String?
    let username: String?
}

final class AuthService {
    private let networkService: NetworkService
    private let userTokenKeychainService = "user_token"
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func signUp(username: String, password: String) async throws {
        let data = try await networkService.post("/sign-up", [
            "username": username,
            "psasword": password
        ])
        
        let response = try parseCodable(type: AuthResponse.self, from: data)
        
        guard response.success, let token = response.token else {
            throw APIError.serverError(message: response.message ?? "Sign up failed")
        }
        
        try? KeychainHelper.standard.save(token, service: userTokenKeychainService)
        
        networkService.token = token
    }
    
    func signIn(username: String, password: String) async throws {
        let data = try await networkService.post("/sign-in", [
            "username": username,
            "password": password
        ])
        
        let response = try parseCodable(type: AuthResponse.self, from: data)
        
        guard response.success, let token = response.token else {
            throw APIError.serverError(message: response.message ?? "Sign in failed")
        }
        
        try? KeychainHelper.standard.save(token, service: userTokenKeychainService)
        
        networkService.token = token
    }
    
    func isAuthenticated() async throws -> Bool {
        guard let token = networkService.token else {
            return false
        }
       
        let data = try await networkService.post("/me", [
            "token": token
        ])
        
        let response = try parseCodable(type: AuthResponse.self, from: data)
        
        guard response.success else {
            return false
        }
        
        return true
    }
    
    func setTokenFromKeychain() {
        guard let token = try? KeychainHelper.standard.read(service: userTokenKeychainService, type: String.self) else {
            return
        }
        
        networkService.token = token
    }
}
