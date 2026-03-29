//
//  Toilets.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import CoreLocation

/// Represents a toilet location returned from the API.
/// Includes coordinates, rating, and whether it's free to use.
struct Toilets: Codable, Hashable, Identifiable {
    let toiletId: Int
    let userCreator: String
    let toiletName: String
    let toiletImageFilename: String?
    let imageUrl: String?
    let aiDescription: String?
    let description: String
    let latitude: String
    let longitude: String
    let avgStar: Float
    let isFree: Bool

    var id: Int { toiletId }

    /// Convert stored lat/long strings to a MapKit-compatible coordinate
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: Double(latitude) ?? 0,
            longitude: Double(longitude) ?? 0
        )
    }

    /// Calculate distance in kilometres from a given coordinate
    func distance(from location: CLLocationCoordinate2D) -> Double {
        let toiletLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return toiletLocation.distance(from: userLocation) / 1000.0
    }

    /// Formatted distance string (e.g. "0.3 km" or "150 m")
    func formattedDistance(from location: CLLocationCoordinate2D) -> String {
        let km = distance(from: location)
        if km < 1 {
            return String(format: "%.0f m", km * 1000)
        } else {
            return String(format: "%.1f km", km)
        }
    }
}
