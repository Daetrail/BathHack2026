//
//  ToiletViewModel.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//
import SwiftUI

@Observable
class ToiletViewModel {
    var navigateToAddReview: Bool = false

    func goToAddReview() {
        navigateToAddReview = true
    }
}
