import SwiftUI

@Observable
class SignInViewModel {
    var navigateToList = false
        
    var userNameInput: String = ""
    var passwordInput: String = ""
    var showError: Bool = false
    
    func isValidUserName(_ userName: String) -> Bool {
        //database implementation pending
        return !userName.isEmpty
    }
    
    func isValidPassword(_ password: String) -> Bool {
        //database implementation pending
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


