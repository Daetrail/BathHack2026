//
//  MockData.swift
//  BathHack2026
//
struct MockData {
    static let toilets: [Toilets] = [
        Toilets(
            toiletId: "1",
            toiletName: "Bath Spa Station Toilet",
            description: "Clean public toilet near the train station. 6767676767676767676767677667676767676767676767676",
            latitude: "51.3781",
            longitude: "-2.3597",
            avgStar: 4
        ),
        Toilets(
            toiletId: "2",
            toiletName: "Roman Baths Public WC",
            description: "Located near the Roman Baths in the city centre.",
            latitude: "51.3814",
            longitude: "-2.3590",
            avgStar: 3
        ),
        Toilets(
            toiletId: "3",
            toiletName: "Southgate Shopping Centre",
            description: "Inside the shopping centre, requires purchase.",
            latitude: "51.3765",
            longitude: "-2.3601",
            avgStar: 5
        ),
        Toilets(
            toiletId: "4",
            toiletName: "67 toilet",
            description: "676961",
            latitude: "51.3765",
            longitude: "-2.3601",
            avgStar: 1
        )
    ]

    static let reviews: [Reviews] = [
        Reviews(
            reviewId: "r1",
            toiletId: "1",
            star: 5,
            title: "Very Clean",
            description: "Spotless and well maintained."
        ),
        Reviews(
            reviewId: "r2",
            toiletId: "1",
            star: 3,
            title: "Decent",
            description: "Could do with more frequent cleaning."
        ),
        Reviews(
            reviewId: "r3",
            toiletId: "2",
            star: 3,
            title: "Average",
            description: "Gets very busy during tourist season."
        )
    ]
}
