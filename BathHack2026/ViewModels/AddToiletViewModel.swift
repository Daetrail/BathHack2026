//
//  AddToiletViewModel.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//

import SwiftUI

@Observable
class AddToiletViewModel {
    var navigateToList = false
        
    var toiletName: String = ""
    var toiletDescription: String = ""
    var longitude: String = ""
    var latitude: String = ""
    var showError: Bool = false
    
    func isValidUserName(_ userName: String) -> Bool {
        return !userName.isEmpty
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return !password.isEmpty
    }
    
    func addToilet() {
        //todo
        navigateToList = true
    }
    
}
