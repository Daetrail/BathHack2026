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
                Text("Welcome")
                    .font(.system(size: 55, weight: .bold))
                    .padding(.bottom, 10)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Username")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 15)
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.secondary)
                        TextField("Username", text: $viewModel.userNameInput)
                            .textContentType(.username)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    .padding()
                    .glassEffect()
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 15)
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                        SecureField("Password", text: $viewModel.passwordInput)
                            .textContentType(.password)
                    }
                    .padding()
                    .glassEffect()
                }
                Button {
                    Task {
                        await viewModel.signIn(appState: appState)
                    }
                } label: {
                    ZStack {
                        Text("Sign In")
                            .opacity(viewModel.isLoading ? 0 : 1)
                        ProgressView()
                            .opacity(viewModel.isLoading ? 1 : 0)
                    }
                    .padding(3)
                    .padding(.horizontal, 40)
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
#Preview {
    SignInView()
        .environment(AppState())
}
