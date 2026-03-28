//
//  RootView.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//
//  Entry point that routes between onboarding (auth) and the main app
//  based on the user's authentication state.
//

import SwiftUI

struct RootView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        Group {
            switch appState.authState {
            case .unknown:
                // Show a loading screen while checking saved session
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.large)
                    Text("Loading...")
                        .foregroundStyle(.secondary)
                }

            case .authenticated:
                // User is signed in — show the main app
                ListView()

            case .unauthenticated, .neverLoggedIn:
                // User needs to sign in or register
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: appState.authState == .authenticated)
        .task {
            // Check for a saved session on launch
            await appState.checkAuth()
        }
    }
}
