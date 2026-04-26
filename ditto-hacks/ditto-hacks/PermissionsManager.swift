//
//  PermissionsManager.swift
//  ditto-hacks
//
//  Centralized permissions management
//

import Foundation
import AVFoundation
import Photos
import UIKit
import Combine

@MainActor
class PermissionsManager: ObservableObject {
    static let shared = PermissionsManager()
    
    @Published var cameraPermissionStatus: PermissionStatus = .notDetermined
    @Published var photoLibraryPermissionStatus: PermissionStatus = .notDetermined
    @Published var microphonePermissionStatus: PermissionStatus = .notDetermined
    
    enum PermissionStatus: Equatable {
        case notDetermined
        case authorized
        case denied
        case restricted
    }
    
    private init() {
        updateAllStatuses()
    }
    
    // MARK: - Status Updates
    
    func updateAllStatuses() {
        Task { @MainActor in
            updateCameraStatus()
            updatePhotoLibraryStatus()
            updateMicrophoneStatus()
        }
    }
    
    private func updateCameraStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        let newStatus = convertAVAuthStatus(status)
        if cameraPermissionStatus != newStatus {
            cameraPermissionStatus = newStatus
            print("📷 Camera permission updated: \(newStatus)")
        }
    }
    
    private func updatePhotoLibraryStatus() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        let newStatus = convertPHAuthStatus(status)
        if photoLibraryPermissionStatus != newStatus {
            photoLibraryPermissionStatus = newStatus
            print("📸 Photo Library permission updated: \(newStatus)")
        }
    }
    
    private func updateMicrophoneStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        let newStatus = convertAVAuthStatus(status)
        if microphonePermissionStatus != newStatus {
            microphonePermissionStatus = newStatus
            print("🎤 Microphone permission updated: \(newStatus)")
        }
    }
    
    // MARK: - Request Permissions
    
    func requestCameraPermission() async -> Bool {
        print("🎬 Requesting camera permission...")
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        print("🎬 Camera permission result: \(granted)")
        
        // Update status on main actor
        await MainActor.run {
            updateCameraStatus()
        }
        
        return granted
    }
    
    func requestPhotoLibraryPermission() async -> Bool {
        print("📚 Requesting photo library permission...")
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        let granted = status == .authorized || status == .limited
        print("📚 Photo library permission result: \(status) (granted: \(granted))")
        
        // Update status on main actor
        await MainActor.run {
            updatePhotoLibraryStatus()
        }
        
        return granted
    }
    
    func requestMicrophonePermission() async -> Bool {
        print("🎙️ Requesting microphone permission...")
        let granted = await AVCaptureDevice.requestAccess(for: .audio)
        print("🎙️ Microphone permission result: \(granted)")
        
        // Update status on main actor
        await MainActor.run {
            updateMicrophoneStatus()
        }
        
        return granted
    }
    
    func requestAllPermissions() async {
        await requestCameraPermission()
        await requestPhotoLibraryPermission()
        await requestMicrophonePermission()
    }
    
    // MARK: - Helpers
    
    private func convertAVAuthStatus(_ status: AVAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .notDetermined
        }
    }
    
    private func convertPHAuthStatus(_ status: PHAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .authorized, .limited:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .notDetermined
        }
    }
    
    // MARK: - Open Settings
    
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
