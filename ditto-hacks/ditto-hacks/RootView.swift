//
//  RootView.swift
//  ditto-hackathon
//
//  ⚠️ THIS FILE IS NO LONGER USED
//  The new RootView is inside DittoApp.swift
//  This file is kept for reference only

import SwiftUI

struct OldRootView: View {
    @State private var isLoadingComplete = false
    @State private var isLoggedIn = false
    @State private var hasCompletedOnboarding = false
    @State private var hasCompletedOpening = false

    var body: some View {
        if !isLoadingComplete {
            // Show DNA loading animation for 3 seconds on app startup
            DNALoadingView(isLoadingComplete: $isLoadingComplete)
        } else if !isLoggedIn {
            // LoginView(isLoggedIn: $isLoggedIn) // OLD - replaced with AuthView
            Text("Login View - Use AuthView instead")
        } else if !hasCompletedOnboarding {
            OnboardingFlow(hasCompletedOnboarding: $hasCompletedOnboarding)
        } else if !hasCompletedOpening {
            OpeningScene(hasCompletedOpening: $hasCompletedOpening)
        } else {
            ContentView()
        }
    }
}

#Preview {
    OldRootView()
}
