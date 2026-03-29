//
//  ToiletDetailViewModel.swift
//  BathHack2026
//
//  Manages the toilet detail screen: loads reviews, handles directions,
//  and manages the review submission sheet.
//

import CoreLocation
import MapKit
import SwiftUI

@Observable
class ToiletDetailViewModel {
    let toilet: Toilets

    // MARK: - Reviews
    var reviews: [Reviews] = []
    var isLoadingReviews = false

    // MARK: - Review submission
    var showAddReview = false
    var reviewStar: Int = 5
    var reviewTitle: String = ""
    var reviewDescription: String = ""
    var isSubmittingReview = false
    var showReviewError = false
    var reviewErrorMessage: String = ""
    var didSubmitReview = false

    // MARK: - Delete toilet
    var showDeleteToiletConfirmation = false
    var isDeletingToilet = false
    var didDeleteToilet = false

    // MARK: - Delete review
    var reviewToDelete: Reviews?
    var showDeleteReviewConfirmation = false
    var isDeletingReview = false

    // MARK: - General
    var showError = false
    var errorMessage: String = ""

    init(toilet: Toilets) {
        self.toilet = toilet
    }

    // MARK: - Load reviews

    /// Fetch all reviews for this toilet from the backend
    func loadReviews() async {
        isLoadingReviews = true
        defer { isLoadingReviews = false }

        do {
            reviews = try await ServiceContainer.shared.reviewService.getReviews(toiletId: toilet.toiletId)
        } catch {
            // Silently fail — the UI will show "No reviews yet"
            reviews = []
        }
    }

    // MARK: - Submit review

    /// Submit a new review for this toilet
    func submitReview() async {
        guard !reviewTitle.trimmingCharacters(in: .whitespaces).isEmpty,
              !reviewDescription.trimmingCharacters(in: .whitespaces).isEmpty else {
            reviewErrorMessage = "Please fill in all fields."
            showReviewError = true
            return
        }

        isSubmittingReview = true
        defer { isSubmittingReview = false }

        let newReview = NewReview(
            toiletId: toilet.toiletId,
            star: reviewStar,
            title: reviewTitle.trimmingCharacters(in: .whitespaces),
            description: reviewDescription.trimmingCharacters(in: .whitespaces)
        )

        do {
            try await ServiceContainer.shared.reviewService.createReview(newReview: newReview, reviewImage: nil)
            didSubmitReview = true
            // Reset the form
            reviewTitle = ""
            reviewDescription = ""
            reviewStar = 5
            showAddReview = false
            // Refresh reviews to show the new one
            await loadReviews()
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                reviewErrorMessage = message
            }
            showReviewError = true
        } catch {
            reviewErrorMessage = "Failed to submit review. Please try again."
            showReviewError = true
        }
    }

    // MARK: - Directions

    /// Open Apple Maps with walking directions to this toilet
    func openDirections() {
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: toilet.coordinate))
        destination.name = toilet.toiletName
        destination.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }

    // MARK: - Delete toilet

    /// Delete this toilet from the backend (owner only).
    /// The database uses ON DELETE CASCADE, so all reviews for this toilet
    /// are automatically removed when the toilet is deleted.
    func deleteToilet() async {
        isDeletingToilet = true
        defer { isDeletingToilet = false }

        do {
            try await ServiceContainer.shared.toiletService.deleteToilet(toiletId: toilet.toiletId)
            didDeleteToilet = true
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            }
            showError = true
        } catch {
            errorMessage = "Failed to delete toilet."
            showError = true
        }
    }

    // MARK: - Delete review

    /// Delete a specific review (owner only)
    func deleteReview(_ review: Reviews) async {
        isDeletingReview = true
        defer { isDeletingReview = false }

        do {
            try await ServiceContainer.shared.reviewService.deleteReview(reviewId: review.reviewId)
            // Refresh reviews list after deletion
            await loadReviews()
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            }
            showError = true
        } catch {
            errorMessage = "Failed to delete review."
            showError = true
        }
    }

    /// Distance string from the user's location to this toilet
    func distanceString(from location: CLLocationCoordinate2D?) -> String? {
        guard let location else { return nil }
        return toilet.formattedDistance(from: location)
    }
}
