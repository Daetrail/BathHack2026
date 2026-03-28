//
//  ReviewService.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation

struct ReviewPayload: Codable {
    let success: Bool
    let message: String?
    let reviews: [Reviews]?
}

struct NewReview: Codable {
    let toiletId: Int
    let star: Int
    let title: String
    let description: String
}

final class ReviewService {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func getReviews(toiletId: Int) async throws -> [Reviews] {
        let data = try await networkService.get("/get-reviews?toiletId=\(toiletId)")
        
        let response = try parseCodable(type: ReviewPayload.self, from: data)
        
        guard response.success, let reviews = response.reviews else {
            throw APIError.serverError(message: response.message ?? "Failed to fetch reviews")
        }
        
        return reviews
    }
    
    func createReview(newReview: NewReview) async throws {
        let data = try await networkService.post("/create-review", newReview)
        
        let response = try parseCodable(type: ReviewPayload.self, from: data)
        
        guard response.success else {
            throw APIError.serverError(message: response.message ?? "Failed to create review")
        }
    }
}
