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

@MainActor
class PermissionsManager: ObservableObject {
    static let shared = PermissionsManager()
    
    @Published var cameraPermissionStatus: PermissionStatus = .notDetermined
    @Published var photoLibraryPermissionStatus: PermissionStatus = .notDetermined
    @Published var microphonePermissionStatus: PermissionStatus = .notDetermined
    
    enum PermissionStatus {
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
        updateCameraStatus()
        updatePhotoLibraryStatus()
        updateMicrophoneStatus()
    }
    
    private func updateCameraStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraPermissionStatus = convertAVAuthStatus(status)
    }
    
    private func updatePhotoLibraryStatus() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        photoLibraryPermissionStatus = convertPHAuthStatus(status)
    }
    
    private func updateMicrophoneStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        microphonePermissionStatus = convertAVAuthStatus(status)
    }
    
    // MARK: - Request Permissions
    
    func requestCameraPermission() async -> Bool {
        let status = await AVCaptureDevice.requestAccess(for: .video)
        updateCameraStatus()
        return status
    }
    
    func requestPhotoLibraryPermission() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        updatePhotoLibraryStatus()
        return status == .authorized
    }
    
    func requestMicrophonePermission() async -> Bool {
        let status = await AVCaptureDevice.requestAccess(for: .audio)
        updateMicrophoneStatus()
        return status
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
