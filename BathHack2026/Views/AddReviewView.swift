//
//  AddReviewView.swift
//  BathHack2026
//
//  Sheet view for submitting a review on a toilet.
//  Includes a tappable star rating, title, and description fields.
//

import SwiftUI

struct AddReviewView: View {
    @Bindable var viewModel: ToiletDetailViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Toilet being reviewed
                    Text("Reviewing: \(viewModel.toilet.toiletName)")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    // MARK: - Star rating picker
                    VStack(spacing: 8) {
                        Text("Rating")
                            .font(.headline)

                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    viewModel.reviewStar = star
                                } label: {
                                    Image(systemName: star <= viewModel.reviewStar ? "star.fill" : "star")
                                        .font(.largeTitle)
                                        .foregroundStyle(.yellow)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Text(ratingLabel(viewModel.reviewStar))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // MARK: - Title field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Title")
                            .font(.headline)
                        TextField("e.g. Spotlessly clean!", text: $viewModel.reviewTitle)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                    }

                    // MARK: - Description field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description")
                            .font(.headline)
                        TextField("Share your experience...", text: $viewModel.reviewDescription, axis: .vertical)
                            .lineLimit(3...8)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                    }

                    // MARK: - Submit button
                    Button {
                        Task {
                            await viewModel.submitReview()
                        }
                    } label: {
                        ZStack {
                            Text("Submit Review")
                                .font(.headline)
                                .opacity(viewModel.isSubmittingReview ? 0 : 1)

                            ProgressView()
                                .opacity(viewModel.isSubmittingReview ? 1 : 0)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 56)
                    .buttonStyle(.glassProminent)
                    .disabled(viewModel.isSubmittingReview)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Review Error", isPresented: $viewModel.showReviewError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.reviewErrorMessage)
            }
        }
    }

    /// Descriptive label for the selected star rating
    private func ratingLabel(_ stars: Int) -> String {
        switch stars {
        case 1: return "Terrible — avoid at all costs"
        case 2: return "Poor — needs improvement"
        case 3: return "Average — gets the job done"
        case 4: return "Good — clean and pleasant"
        case 5: return "Excellent — pristine facilities"
        default: return ""
        }
    }
}
