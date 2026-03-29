//
//  Reviews.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation

/// Represents a user review for a toilet.
/// Includes star rating, text, and the reviewer's username.
struct Reviews: Codable, Hashable, Identifiable {
    let reviewId: Int
    let toiletId: Int
    let reviewImageFilename: String?
    let imageUrl: String?
    let userCreator: String
    let star: Float
    let title: String
    let description: String
    let date: Date

    var id: Int { reviewId }

    /// Formatted date string for display (e.g. "28 Mar 2026")
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
