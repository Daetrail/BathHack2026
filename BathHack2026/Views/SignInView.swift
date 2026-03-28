//
//  AgeView.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//

import SwiftUI

struct SignInView: View {
    @State private var viewModel = RegisterViewModel()
    
    var body: some View {
        NavigationStack {
            Spacer()
            
            Text("Sign In To Your Existing Account")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
            
            VStack (spacing: 20) {
                
                TextField("Username", text: $viewModel.userNameInput)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                
                SecureField("Password", text: $viewModel.passwordInput)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                
                Button {
                    viewModel.register()
                } label: {
                    Text("Sign In")
                        .font(.title)
                        .padding(.horizontal, 30)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .buttonStyle(.glassProminent)
                
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .fullScreenCover(isPresented: $viewModel.navigateToList) {
            ListView()
        }
        .alert("Invalid Credentials", isPresented: $viewModel.showError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Please enter a valid username and password.")
                }
    }
}
    
struct SignIn_Previews: PreviewProvider {
        static var previews: some View {
            SignInView()
        }
    }
