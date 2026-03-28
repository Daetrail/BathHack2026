//
//  ToiletView.swift
//  BathHack2026
//
//  Full detail view for a toilet. Shows location on a mini-map,
//  info (name, rating, free/paid, distance), directions button,
//  list of reviews, and a button to write a new review.
//

import MapKit
import SwiftUI

struct ToiletView: View {
    let toilet: Toilets
    @Environment(LocationService.self) var locationService
    @State private var viewModel: ToiletDetailViewModel

    init(toilet: Toilets) {
        self.toilet = toilet
        self._viewModel = State(initialValue: ToiletDetailViewModel(toilet: toilet))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Mini map showing toilet location
                miniMap

                // MARK: - Toilet info section
                infoSection

                Divider().padding(.horizontal)

                // MARK: - Action buttons (directions + review)
                actionButtons

                Divider().padding(.horizontal)

                // MARK: - Reviews section
                reviewsSection
            }
        }
        .navigationTitle(toilet.toiletName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadReviews()
        }
        // MARK: - Add Review sheet
        .sheet(isPresented: $viewModel.showAddReview) {
            AddReviewView(viewModel: viewModel)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    // MARK: - Mini Map

    private var miniMap: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: toilet.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))) {
            Marker(toilet.toiletName, coordinate: toilet.coordinate)
                .tint(.red)
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .frame(height: 200)
        .allowsHitTesting(false) // Prevent map interaction — it's just a preview
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Name + badges
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(toilet.toiletName)
                        .font(.title2.bold())

                    HStack(spacing: 8) {
                        // Free/Paid badge
                        if toilet.isFree {
                            Label("Free", systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        } else {
                            Label("Paid", systemImage: "sterlingsign.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                        }

                        // Distance from user
                        if let userLoc = locationService.latitude,
                           let userLon = locationService.longitude {
                            let userCoord = CLLocationCoordinate2D(
                                latitude: userLoc, longitude: userLon
                            )
                            Label(
                                toilet.formattedDistance(from: userCoord),
                                systemImage: "location.fill"
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                // Star rating
                VStack(spacing: 4) {
                    if toilet.avgStar > 0 {
                        Text(String(format: "%.1f", toilet.avgStar))
                            .font(.title.bold())
                        starRating(toilet.avgStar)
                    } else {
                        Text("New")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("No reviews")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Description
            Text(toilet.description)
                .font(.body)
                .foregroundStyle(.secondary)

            // Added by
            Text("Added by @\(toilet.userCreator)")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Coordinates
            Text("📍 \(toilet.latitude), \(toilet.longitude)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            // Get Directions — opens Apple Maps with walking route
            Button {
                viewModel.openDirections()
            } label: {
                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 50)
            .buttonStyle(.glassProminent)
            .tint(.blue)

            // Write a Review
            Button {
                viewModel.showAddReview = true
            } label: {
                Label("Write a Review", systemImage: "square.and.pencil")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 50)
            .buttonStyle(.glass)
        }
        .padding()
    }

    // MARK: - Reviews Section

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reviews")
                    .font(.title3.bold())
                Text("(\(viewModel.reviews.count))")
                    .foregroundStyle(.secondary)
            }

            if viewModel.isLoadingReviews {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            } else if viewModel.reviews.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "text.bubble")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No reviews yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Be the first to review this toilet!")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(viewModel.reviews) { review in
                    reviewCard(review)
                }
            }
        }
        .padding()
    }

    /// Individual review card
    private func reviewCard(_ review: Reviews) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // Star rating
                HStack(spacing: 2) {
                    ForEach(1..<6) { star in
                        Image(systemName: Float(star) <= review.star ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }

                Spacer()

                Text("@\(review.userCreator)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(review.title)
                .font(.subheadline.bold())

            Text(review.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(review.formattedDate)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }

    /// Star rating display
    private func starRating(_ rating: Float) -> some View {
        HStack(spacing: 2) {
            ForEach(1..<6) { star in
                Image(systemName: Float(star) <= rating ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }
    }
}
