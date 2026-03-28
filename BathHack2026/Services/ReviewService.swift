//
//  ReviewService.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation

/// API response wrapper for review endpoints
struct ReviewPayload: Codable {
    let success: Bool
    let message: String?
    let reviews: [Reviews]?
}

/// Request body for creating a new review
struct NewReview: Codable {
    let toiletId: Int
    let star: Int
    let title: String
    let description: String
}

/// Handles all review-related API operations: fetch and create.
final class ReviewService {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    /// Fetch reviews for a specific toilet.
    /// The backend filters by toiletId via query parameter.
    func getReviews(toiletId: Int) async throws -> [Reviews] {
        let data = try await networkService.get("/get-reviews?toiletId=\(toiletId)")
        let response = try parseCodable(type: ReviewPayload.self, from: data)

        guard response.success, let reviews = response.reviews else {
            throw APIError.serverError(message: response.message ?? "Failed to fetch reviews")
        }

        return reviews
    }

    /// Submit a new review for a toilet
    func createReview(newReview: NewReview) async throws {
        let data = try await networkService.post("/create-review", newReview)
        let response = try parseCodable(type: ReviewPayload.self, from: data)

        guard response.success else {
            throw APIError.serverError(message: response.message ?? "Failed to create review")
        }
    }

    /// Delete a review by its ID (must be the owner)
    func deleteReview(reviewId: Int) async throws {
        let data = try await networkService.delete("/delete-review", ["reviewId": reviewId])
        let response = try parseCodable(type: ReviewPayload.self, from: data)

        guard response.success else {
            throw APIError.serverError(message: response.message ?? "Failed to delete review")
        }
    }
}
