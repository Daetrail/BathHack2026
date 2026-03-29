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
            ZStack {
                Image("bgnew")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // App branding
                    VStack(spacing: 12) {
                        Text("Find My Toilet")
                            .font(.system(size: 56, design: .serif))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                        Text("Nature doesn't wait - And neither should you.")
                            .font(.title2)
                            .foregroundStyle(.primary.opacity(0.95))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 30)
                    
                    // Auth buttons
                    VStack(spacing: 16) {
                        Button {
                            viewModel.goToSignIn()
                        } label: {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 20))
                                .padding(.vertical, 10)
                        }
                        .frame(maxWidth: .infinity, minHeight: 68)
                        .buttonStyle(.glassProminent)
                        Button {
                            viewModel.goToRegister()
                        } label: {
                            Text("Register")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 20))
                                .padding(.vertical, 10)
                        }
                        .frame(maxWidth: .infinity, minHeight: 68)
                        .buttonStyle(.glass)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 60)
                }
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
#Preview {
    OnboardingView()
}
