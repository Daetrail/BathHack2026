//
//  ListViewModel.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//
//  Main home screen view model. Manages toilet data, search/filter/sort,
//  map state, and the "Code Brown" emergency feature.
//

import CoreLocation
import MapKit
import SwiftUI

/// Controls how toilets are sorted in the list/map
enum SortMode: String, CaseIterable {
    case distance = "Nearest"
    case rating = "Top Rated"
    case name = "Name A-Z"
}

@Observable
class ListViewModel {
    // MARK: - Navigation
    var navigateToAddToilet = false
    var selectedToilet: Toilets? = nil

    // MARK: - Data
    var toilets: [Toilets] = []
    var searchText: String = ""
    var sortMode: SortMode = .distance
    var isLoading = false
    var errorMessage: String?

    // MARK: - Map state
    var mapCameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    var selectedMapToiletId: Int? = nil

    // MARK: - Location
    var userLocation: CLLocationCoordinate2D? = nil

    // MARK: - Code Brown
    var codeBrownToilet: Toilets? = nil
    var showCodeBrownAlert = false

    /// The currently selected toilet on the map (looked up from selectedMapToiletId)
    var selectedMapToilet: Toilets? {
        guard let id = selectedMapToiletId else { return nil }
        return toilets.first { $0.toiletId == id }
    }

    /// Toilets filtered by search text and sorted by the chosen sort mode
    var filteredToilets: [Toilets] {
        var result = toilets

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.toiletName.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort based on selected mode
        switch sortMode {
        case .distance:
            if let location = userLocation {
                result.sort { $0.distance(from: location) < $1.distance(from: location) }
            }
        case .rating:
            result.sort { $0.avgStar > $1.avgStar }
        case .name:
            result.sort { $0.toiletName < $1.toiletName }
        }

        return result
    }

    // MARK: - API

    /// Fetch all toilets from the backend
    func loadToilets() async {
        isLoading = true
        defer { isLoading = false }

        do {
            toilets = try await ServiceContainer.shared.toiletService.getToilets()
            errorMessage = nil
        } catch {
            errorMessage = "Could not load toilets. Pull to refresh."
        }
    }

    // MARK: - Navigation helpers

    func goToAddToilet() {
        navigateToAddToilet = true
    }

    func goToToilet(_ toilet: Toilets) {
        selectedToilet = toilet
    }

    // MARK: - Code Brown

    /// Find the best nearby toilet: weighted by rating and distance.
    /// Score = avgStar / (1 + distance_km) — closer + higher rated = better.
    func triggerCodeBrown() {
        guard let location = userLocation else {
            // No location — just pick the highest rated
            codeBrownToilet = toilets.filter { $0.avgStar > 0 }.max(by: { $0.avgStar < $1.avgStar })
            showCodeBrownAlert = codeBrownToilet != nil
            return
        }

        // Score each toilet by rating and proximity
        codeBrownToilet = toilets
            .filter { $0.avgStar > 0 }
            .max { a, b in
                let scoreA = Double(a.avgStar) / (1.0 + a.distance(from: location))
                let scoreB = Double(b.avgStar) / (1.0 + b.distance(from: location))
                return scoreA < scoreB
            }

        // If no reviewed toilets, fall back to the nearest one
        if codeBrownToilet == nil {
            codeBrownToilet = toilets.min { a, b in
                a.distance(from: location) < b.distance(from: location)
            }
        }

        showCodeBrownAlert = codeBrownToilet != nil
    }
}
