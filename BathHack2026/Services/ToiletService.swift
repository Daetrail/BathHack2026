//
//  ToiletService.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation

/// API response wrapper for toilet endpoints
struct ToiletPayload: Codable {
    let success: Bool
    let message: String?
    let toilets: [Toilets]?
}

/// Request body for creating a new toilet
struct NewToilet: Codable {
    let toiletName: String
    let description: String
    let latitude: String
    let longitude: String
    let isFree: Bool
}

/// Handles all toilet-related API operations: fetch, create, and delete.
final class ToiletService {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    /// Fetch all toilets from the server
    func getToilets() async throws -> [Toilets] {
        let data = try await networkService.get("/get-toilets")
        let response = try parseCodable(type: ToiletPayload.self, from: data)

        guard response.success, let toilets = response.toilets else {
            throw APIError.serverError(message: response.message ?? "Failed to get toilets")
        }

        return toilets
    }

    /// Create a new toilet listing on the server
    func createToilet(newToilet: NewToilet, toiletImage: Data?) async throws {
        var imageFilename: String? = nil
        if toiletImage != nil {
            imageFilename = UUID().uuidString + ".jpg"
        }
        
        let data = try await networkService.postWithJpeg("/create-toilet", newToilet, jpegFilename: imageFilename, jpegData: toiletImage)
        let response = try parseCodable(type: ToiletPayload.self, from: data)

        guard response.success else {
            throw APIError.serverError(message: response.message ?? "Failed to create toilet")
        }
    }

    /// Delete a toilet by its ID (must be the owner)
    func deleteToilet(toiletId: Int) async throws {
        let data = try await networkService.delete("/delete-toilet", ["toiletId": toiletId])
        let response = try parseCodable(type: ToiletPayload.self, from: data)

        guard response.success else {
            throw APIError.serverError(message: response.message ?? "Failed to delete toilet")
        }
    }
}
