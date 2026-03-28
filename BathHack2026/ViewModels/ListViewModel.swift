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
    
    func goToAddToilet() {
        navigateToAddToilet = true
    }
    
    var filteredToilets: [Toilets] {
            if searchText.isEmpty {
                return toilets
            } else {
                return toilets.filter { $0.toiletName.localizedCaseInsensitiveContains(searchText) }
            }
        }
}
