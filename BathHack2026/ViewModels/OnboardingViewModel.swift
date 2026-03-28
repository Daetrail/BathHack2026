//
//  File.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//

import SwiftUI
import Observation

@Observable
class OnboardingViewModel {
    var navigateToSignIn = false
    var navigateToRegister = false

    func goToSignIn() {
        navigateToSignIn = true
    }

    func goToRegister() {
        navigateToRegister = true
    }
}
