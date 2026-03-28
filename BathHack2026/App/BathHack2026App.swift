//
//  BathHack2026App.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import SwiftUI

@main
struct BathHack2026App: App {
    @State private var locationService = LocationService()
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(locationService)
                .environment(appState)
        }
    }
}
