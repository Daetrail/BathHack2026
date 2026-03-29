//
//  OnboardingView.swift
//  BathHack2026
//
//  Welcome screen with sign in and register options.
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                // App branding
                VStack(spacing: 12) {
                    Image(systemName: "toilet.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)

                    Text("Find My Toilet")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    Text("Never get caught short again")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Auth buttons
                VStack(spacing: 16) {
                    Button {
                        viewModel.goToSignIn()
                    } label: {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                    .frame(width: 120, height: 56)
                    .buttonStyle(.glassProminent)

                    Button {
                        viewModel.goToRegister()
                    } label: {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                    }
                    .frame(width: 120, height: 56)
                    .tint(.gray)
                    .buttonStyle(.glassProminent)
                }
                
                Spacer()
            }
            .navigationDestination(isPresented: $viewModel.navigateToSignIn) {
                SignInView()
            }
            .navigationDestination(isPresented: $viewModel.navigateToRegister) {
                RegisterView()
            }
        }
        
    }
}
