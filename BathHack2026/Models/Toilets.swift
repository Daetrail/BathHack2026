//
//  Toilets.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

struct Toilets: Codable {
    let toiletId: Int
    let userCreator: String
    let toiletName: String
    let aiDescription: String?
    let description: String
    let latitude: String
    let longitude: String
    let avgStar: Float
}
