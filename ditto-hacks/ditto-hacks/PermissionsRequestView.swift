//
//  PermissionsRequestView.swift
//  ditto-hacks
//
//  View to request necessary permissions from user
//

import SwiftUI

struct PermissionsRequestView: View {
    @StateObject private var permissionsManager = PermissionsManager.shared
    @State private var isRequestingPermissions = false
    @State private var showSettingsAlert = false
    let onComplete: () -> Void
    
    var allPermissionsGranted: Bool {
        permissionsManager.cameraPermissionStatus == .authorized &&
        permissionsManager.photoLibraryPermissionStatus == .authorized
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                }
                
                // Title
                Text("Permissions Needed")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Description
                Text("To verify your tasks with photos, we need access to your camera and photo library.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Permission Items
                VStack(spacing: 16) {
                    PermissionRow(
                        icon: "camera.fill",
                        title: "Camera",
                        description: "Take photos to verify task completion",
                        status: permissionsManager.cameraPermissionStatus
                    )
                    
                    PermissionRow(
                        icon: "photo.on.rectangle",
                        title: "Photo Library",
                        description: "Choose photos for verification",
                        status: permissionsManager.photoLibraryPermissionStatus
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    if allPermissionsGranted {
                        // Continue button
                        Button(action: {
                            onComplete()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                Text("Continue")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0.0, green: 0.9, blue: 0.4))
                            .cornerRadius(16)
                        }
                    } else {
                        // Request permissions button
                        Button(action: {
                            requestPermissions()
                        }) {
                            HStack {
                                if isRequestingPermissions {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "lock.open.fill")
                                        .font(.system(size: 20))
                                    Text("Grant Permissions")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0.0, green: 0.9, blue: 0.4))
                            .cornerRadius(16)
                        }
                        .disabled(isRequestingPermissions)
                        
                        // Skip for now button
                        Button(action: {
                            onComplete()
                        }) {
                            Text("Skip for Now")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .alert("Open Settings", isPresented: $showSettingsAlert) {
            Button("Open Settings") {
                permissionsManager.openAppSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Some permissions were denied. You can enable them in Settings.")
        }
        .onAppear {
            // Refresh statuses when view appears
            permissionsManager.updateAllStatuses()
        }
    }
    
    private func requestPermissions() {
        Task { @MainActor in
            isRequestingPermissions = true
            
            // Small delay to ensure UI updates
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            // Request camera first
            if permissionsManager.cameraPermissionStatus == .notDetermined {
                let cameraGranted = await permissionsManager.requestCameraPermission()
                print("Camera permission granted: \(cameraGranted)")
            }
            
            // Small delay between requests
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            // Then photo library
            if permissionsManager.photoLibraryPermissionStatus == .notDetermined {
                let photoGranted = await permissionsManager.requestPhotoLibraryPermission()
                print("Photo library permission granted: \(photoGranted)")
            }
            
            // Force status update
            permissionsManager.updateAllStatuses()
            
            isRequestingPermissions = false
            
            // Check if any were denied
            if permissionsManager.cameraPermissionStatus == .denied ||
               permissionsManager.photoLibraryPermissionStatus == .denied {
                showSettingsAlert = true
            }
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let status: PermissionsManager.PermissionStatus
    
    var statusIcon: String {
        switch status {
        case .authorized:
            return "checkmark.circle.fill"
        case .denied, .restricted:
            return "xmark.circle.fill"
        case .notDetermined:
            return "circle"
        }
    }
    
    var statusColor: Color {
        switch status {
        case .authorized:
            return Color(red: 0.0, green: 0.9, blue: 0.4)
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .white.opacity(0.3)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Status
            Image(systemName: statusIcon)
                .font(.system(size: 24))
                .foregroundColor(statusColor)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    PermissionsRequestView(onComplete: {})
}
