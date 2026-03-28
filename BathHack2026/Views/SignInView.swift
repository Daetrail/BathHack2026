//
//  SignInView.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//
//  Sign in form that authenticates against the backend API.
//

import SwiftUI

struct SignInView: View {
    @Environment(AppState.self) var appState
    @State private var viewModel = SignInViewModel()

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                Text("Welcome Back")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.bottom, 10)

                TextField("Username", text: $viewModel.userNameInput)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                SecureField("Password", text: $viewModel.passwordInput)
                    .textContentType(.password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                Button {
                    Task {
                        await viewModel.signIn(appState: appState)
                    }
                } label: {
                    ZStack {
                        Text("Sign In")
                            .font(.system(size: 20))
                            .opacity(viewModel.isLoading ? 0 : 1)

                        ProgressView()
                            .opacity(viewModel.isLoading ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 56)
                .buttonStyle(.glassProminent)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .alert("Sign In Failed", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}
