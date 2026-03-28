//
//  AppState.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation
import SocketIO

@MainActor
@Observable
final class AppState {
    enum AuthState {
        case unknown          // App just launched
        case authenticated
        case unauthenticated
        case neverLoggedIn    // First-time user
    }
   
    var authState: AuthState = .unknown
}
