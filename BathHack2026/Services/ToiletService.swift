//
//  ToiletService.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation

struct ToiletPayload: Codable {
    let success: Bool
    let message: String?
    let toilets: [Toilets]?
}

struct NewToilet: Codable {
    let toiletName: String
    let description: String
    let latitude: String
    let longitude: String
}

final class ToiletService {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func getToilets() async throws -> [Toilets] {
        let data = try await networkService.get("/get-toilets")
        
        let response = try parseCodable(type: ToiletPayload.self, from: data)
        
        guard response.success, let toilets = response.toilets else {
            throw APIError.serverError(message: response.message ?? "Failed to get toilets")
        }
        
        return toilets
    }
    
    func createToilet(newToilet: NewToilet) async throws {
        let data = try await networkService.post("/create-toilet", newToilet)
        
        let response = try parseCodable(type: ToiletPayload.self, from: data)
        
        guard response.success else {
            throw APIError.serverError(message: response.message ?? "Failed to create toilet")
        }
    }
}
