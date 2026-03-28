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
    
    func goToAddToilet() {
        navigateToAddToilet = true
    }
}
