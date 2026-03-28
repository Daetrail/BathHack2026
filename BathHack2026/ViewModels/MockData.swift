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
            toiletName: "67 Toilet 12312312312312312312312312312312kl3n12ok3nl1k2n3lk12n3l12n3l21332n3l12kn3kl21n312",
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
            reviewId: 4,
            toiletId: 1,
            userCreator: "oscar",
            star: 3.1,
            title: "Decent",
            description: "Could do with more frequent cleaning.038740872308472985723987041297509237509234705927390587234908572394572934750293487503985793487594037502398759023874509483725908237598043750923780",
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
