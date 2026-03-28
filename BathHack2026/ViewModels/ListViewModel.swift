//
//  ListViewModel.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//

import SwiftUI

@Observable
class ListViewModel {
    var navigateToAddToilet = false
    
    var searchText: String = ""
    var toilets: [Toilets] = MockData.toilets
    var reviews: [Reviews] = MockData.reviews
    var selectedToilet: Toilets? = nil
    
    var filteredToilets: [Toilets] {
            if searchText.isEmpty {
                return toilets
            } else {
                return toilets.filter { $0.toiletName.localizedCaseInsensitiveContains(searchText) }
            }
        }
    
    func goToAddToilet() {
        navigateToAddToilet = true
    }
    
    func goToToilet(_ toilet: Toilets) {
        selectedToilet = toilet
    }
    
}
