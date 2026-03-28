//
//  MockData.swift
//  BathHack2026
//
import Foundation

struct MockData {
    static let toilets: [Toilets] = [
        Toilets(
            toiletId: 1,
            userCreator: "oscar",
            toiletName: "Bath Spa Station Toilet",
            aiDescription: nil,
            description: "Clean public toilet near the train station.",
            latitude: "51.3781",
            longitude: "-2.3597",
            avgStar: 3.1
        ),
        Toilets(
            toiletId: 2,
            userCreator: "oscar",
            toiletName: "Roman Baths Public WC",
            aiDescription: nil,
            description: "Located near the Roman Baths in the city centre.",
            latitude: "51.3814",
            longitude: "-2.3590",
            avgStar: 1.9
        ),
        Toilets(
            toiletId: 3,
            userCreator: "oscar",
            toiletName: "Southgate Shopping Centre",
            aiDescription: nil,
            description: "Inside the shopping centre, requires purchase.",
            latitude: "51.3765",
            longitude: "-2.3601",
            avgStar: 5.0
        ),
        Toilets(
            toiletId: 4,
            userCreator: "oscar",
            toiletName: "67 Toilet",
            aiDescription: nil,
            description: "676961",
            latitude: "51.3765",
            longitude: "-2.3601",
            avgStar: 3.7
        )
    ]

    static let reviews: [Reviews] = [
        Reviews(
            reviewId: 1,
            toiletId: 1,
            userCreator: "oscar",
            star: 5.0,
            title: "Very Clean",
            description: "Spotless and well maintained.",
            date: Date()
        ),
        Reviews(
            reviewId: 2,
            toiletId: 1,
            userCreator: "oscar",
            star: 3.1,
            title: "Decent",
            description: "Could do with more frequent cleaning.",
            date: Date()
        ),
        Reviews(
            reviewId: 3,
            toiletId: 2,
            userCreator: "oscar",
            star: 3.5,
            title: "Average",
            description: "Gets very busy during tourist season.",
            date: Date()
        )
    ]
}
