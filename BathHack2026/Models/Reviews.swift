//
//  Reviews.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation

struct Reviews: Codable, Hashable {
    let reviewId: Int
    let toiletId: Int
    let userCreator: String
    let star: Float
    let title: String
    let description: String
    let date: Date
}
