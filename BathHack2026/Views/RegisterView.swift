//
//  RegisterView.swift
//  BathHack2026
//
//  Created by Oscar Leigh on 28/03/2026.
//
//  Registration form that creates a new account via the backend API.
//

import SwiftUI

struct RegisterView: View {
    @Environment(AppState.self) var appState
    @State private var viewModel = RegisterViewModel()

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                Text("Create Account")
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
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                Button {
                    Task {
                        await viewModel.register(appState: appState)
                    }
                } label: {
                    ZStack {
                        Text("Register")
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
        .alert("Registration Failed", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}
