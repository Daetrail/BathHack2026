//
//  RegisterViewModel.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//

import SwiftUI

@Observable
class RegisterViewModel {
        var navigateToOnboarding = false
        
        var userNameInput: String = ""
        var passwordInput: String = ""
    
    func isValidUserName(_ userName: String) -> Bool {
        return !userName.isEmpty
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return !password.isEmpty
    }
    
    func register() {
        if (isValidPassword(passwordInput) && isValidUserName(userNameInput)) {
            navigateToOnboarding = true
        }
    }
}


