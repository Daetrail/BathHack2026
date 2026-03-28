//
//  ListView.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//
import SwiftUI

struct ListView: View {
    @State private var viewModel = ListViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Find My Toilet")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName:"figure.walk.motion.trianglebadge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.primary)
                        .padding(.trailing)
                }
                .padding()

                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                        TextField("Search...", text: $viewModel.searchText)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                    Button {
                        // add action here
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.green)
                            .font(.system(size: 40))
                    }
                }
                .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.toilets, id: \.toiletId) { toilet in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.systemGray6))
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                                .overlay(
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            if toilet.avgStar >= 4 {
                                                    Image(systemName: "crown.fill")
                                                        .foregroundStyle(.yellow)
                                                } else if toilet.avgStar <= 2 {
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                        .foregroundStyle(.red)
                                                }
                                                Text(toilet.toiletName)
                                                    .font(.headline)
                                                    .foregroundStyle(.primary)
                                                Spacer()
                                            HStack(spacing: 4) {
                                                ForEach(1..<6) { star in
                                                    Image(systemName: star <= toilet.avgStar ? "star.fill" : "star")
                                                        .foregroundStyle(.yellow)
                                                }
                                            }
                                        }
                                        Text(toilet.description)
                                            .font(.subheadline)
                                            .foregroundStyle(.gray)
                                            .lineLimit(2)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                )
                        }
                    }
                    .padding()
                }

                Spacer()
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
