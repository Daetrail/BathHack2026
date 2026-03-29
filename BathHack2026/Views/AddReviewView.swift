//
//  AddReviewView.swift
//  BathHack2026
//
//  Sheet view for submitting a review on a toilet.
//  Includes a tappable star rating, title, and description fields.
//

import PhotosUI
import SwiftUI

struct AddReviewView: View {
    @Bindable var viewModel: ToiletDetailViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    @State private var showPhotoSourceDialog = false

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

                    // MARK: - Photo section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Photo (optional)")
                            .font(.headline)

                        Button {
                            showPhotoSourceDialog = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.systemGray6))
                                    .frame(height: 150)

                                if let image = viewModel.reviewSelectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 30))
                                            .foregroundStyle(.secondary)
                                        Text("Tap to add photo")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .confirmationDialog("Add Photo", isPresented: $showPhotoSourceDialog) {
                            Button("Take Photo") { showCamera = true }
                            Button("Choose from Library") { showPhotosPicker = true }
                        }

                        if viewModel.reviewSelectedImage != nil {
                            Button("Remove Photo", role: .destructive) {
                                viewModel.reviewSelectedImage = nil
                                viewModel.reviewSelectedPhoto = nil
                            }
                            .font(.caption)
                        }
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
            .scrollDismissesKeyboard(.interactively)
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
            .photosPicker(isPresented: $showPhotosPicker, selection: $viewModel.reviewSelectedPhoto, matching: .images)
            .fullScreenCover(isPresented: $showCamera) {
                CameraView { image in
                    viewModel.reviewSelectedImage = image
                }
                .ignoresSafeArea()
            }
            .onChange(of: viewModel.reviewSelectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.reviewSelectedImage = image
                    }
                }
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
