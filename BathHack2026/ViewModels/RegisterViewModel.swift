//
//  RegisterViewModel.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//

import SwiftUI

@Observable
class RegisterViewModel {
    var navigateToList = false
        
    var userNameInput: String = ""
    var passwordInput: String = ""
    var showError: Bool = false
    
    func isValidUserName(_ userName: String) -> Bool {
        return !userName.isEmpty
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return !password.isEmpty
    }
    
    func register() {
        if (isValidPassword(passwordInput) && isValidUserName(userNameInput)) {
            navigateToList = true
        } else {
            showError = true
        }
    }
}


