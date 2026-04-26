//
//  DittoApp.swift
//  ditto-hacks
//
//  Main app entry point
//

import SwiftUI

@main
struct DittoApp: App {
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var permissionsManager = PermissionsManager.shared
    @State private var isLoadingComplete = false
    @State private var hasCheckedAuth = false
    @State private var authCheckFailed = false
    @State private var hasRequestedPermissions = false
    
    var shouldShowPermissions: Bool {
        // Only show permissions screen if user is authenticated AND permissions not granted
        return appState.isAuthenticated && 
               !hasRequestedPermissions &&
               (permissionsManager.cameraPermissionStatus != .authorized ||
                permissionsManager.photoLibraryPermissionStatus != .authorized)
    }
    
    var body: some View {
        Group {
            if !isLoadingComplete {
                // DNA Loading Animation
                DNALoadingView(isLoadingComplete: $isLoadingComplete)
            } else if !hasCheckedAuth {
                // Checking authentication
                Color.black
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(.white)
                            Text("Connecting...")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    )
                    .task {
                        // Add timeout protection
                        await withTimeout(seconds: 10) {
                            await appState.checkAuthStatus()
                        }
                        hasCheckedAuth = true
                        
                        // Check if permissions are already granted
                        if permissionsManager.cameraPermissionStatus == .authorized &&
                           permissionsManager.photoLibraryPermissionStatus == .authorized {
                            print("✅ Permissions already granted - skipping permissions screen")
                            hasRequestedPermissions = true
                        }
                    }
            } else if shouldShowPermissions {
                // Request permissions after authentication (only if not already granted)
                PermissionsRequestView {
                    print("🎯 PermissionsRequestView onComplete called")
                    hasRequestedPermissions = true
                }
                .onAppear {
                    print("📱 PermissionsRequestView is now showing")
                }
            } else {
                // Route based on auth and onboarding status
                if !appState.isAuthenticated {
                    AuthView()
                } else if !appState.isOnboarded {
                    DittoOnboardingFlow()
                } else {
                    HomeView()
                }
            }
        }
    }
    
    // Helper function to add timeout to async operations
    private func withTimeout(seconds: TimeInterval, operation: @escaping () async -> Void) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await operation()
            }
            
            group.addTask {
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            }
            
            // Wait for first task to complete (either operation or timeout)
            await group.next()
            
            // Cancel remaining tasks
            group.cancelAll()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState.shared)
}
