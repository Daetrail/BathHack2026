//
//  ToiletView.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//
import SwiftUI

struct ToiletView: View {
    @State private var viewModel = ToiletViewModel()
    let toilet: Toilets

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemGray6))
                    Image(systemName: "toilet")
                        .font(.system(size: 60))
                        .foregroundStyle(.gray)
                }
                .frame(height: geometry.size.height * 0.4)
                .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 4) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(toilet.toiletName)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            HStack(spacing: 6) {
                                ForEach(1..<6) { star in
                                    Image(systemName: Float(star) <= toilet.avgStar ? "star.fill" : "star")
                                        .foregroundStyle(.yellow)
                                        .font(.system(size: 14))
                                }
                                Spacer()
                                    .frame(width: 4)
                                Text(String(format: "%.1f", toilet.avgStar))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.yellow)
                                if toilet.avgStar >= 4 {
                                    Image(systemName: "crown.fill")
                                        .foregroundStyle(.yellow)
                                        .font(.system(size: 14))
                                } else if toilet.avgStar <= 2 {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.red)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 8)

                        Text(toilet.description)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        HStack {
                            Text("Reviews")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.primary)
                            Spacer()
                            Button {
                                viewModel.goToAddReview()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.system(size: 30))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                        .padding(.horizontal)
                        .padding(.bottom, 12)

                        VStack(spacing: 16) {
                            ForEach(MockData.reviews.filter { $0.toiletId == toilet.toiletId }, id: \.reviewId) { review in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.systemGray6))
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(review.title)
                                                .font(.headline)
                                                .foregroundStyle(.primary)
                                            Spacer()
                                            HStack(spacing: 4) {
                                                ForEach(1..<6) { star in
                                                    Image(systemName: Float(star) <= review.star ? "star.fill" : "star")
                                                        .foregroundStyle(.yellow)
                                                        .font(.system(size: 12))
                                                }
                                                Text(String(format: "%.1f", review.star))
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundStyle(.yellow)
                                            }
                                        }
                                        Text(review.description)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                        Text(review.date, style: .date)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToAddReview) {
                AddReviewView(toilet: toilet)
            }
        }
    }
}

struct ToiletView_Previews: PreviewProvider {
    static var previews: some View {
        ToiletView(toilet: MockData.toilets[0])
    }
}
