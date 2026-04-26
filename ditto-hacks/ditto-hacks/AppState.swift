//
//  AppState.swift
//  ditto-hacks
//

import Foundation
import SwiftUI
import UIKit
import Combine

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isAuthenticated = false
    @Published var isOnboarded = false
    @Published var isLoading = false
    @Published var profile: ProfileResponse?
    @Published var errorMessage: String?

    /// AI-graded scores per category for the current day.
    /// key = category, value = 0.0–1.0. Absent key = not submitted = 0%.
    @Published var dailyTaskScores: [String: Float] = [:]

    var token: String? {
        didSet { if let t = token { _ = KeychainHelper.shared.saveToken(t) } }
    }
    var userId: Int? {
        didSet { if let u = userId { _ = KeychainHelper.shared.saveUserId(u) } }
    }

    private init() {}

    func checkAuthStatus() async {
        guard let savedToken = KeychainHelper.shared.getToken() else { return }
        self.token = savedToken
        self.userId = KeychainHelper.shared.getUserId()
        do {
            let profile = try await APIClient.shared.getProfile(token: savedToken)
            self.profile = profile
            self.isAuthenticated = true
            self.isOnboarded = profile.onboarded
        } catch APIError.unauthorized {
            logout()
        } catch {
            self.errorMessage = "Failed to load profile"
        }
    }

    func login(email: String, password: String) async throws {
        isLoading = true; defer { isLoading = false }
        let response = try await APIClient.shared.login(email: email, password: password)
        self.token = response.token
        self.userId = response.user_id
        let profile = try await APIClient.shared.getProfile(token: response.token)
        self.profile = profile
        self.isAuthenticated = true
        self.isOnboarded = profile.onboarded
    }

    func register(email: String, username: String, password: String) async throws {
        isLoading = true; defer { isLoading = false }
        let response = try await APIClient.shared.register(email: email, username: username, password: password)
        self.token = response.token
        self.userId = response.user_id
        self.isAuthenticated = true
        self.isOnboarded = false
    }

    func logout() {
        KeychainHelper.shared.clearAll()
        token = nil; userId = nil; profile = nil
        isAuthenticated = false; isOnboarded = false
    }

    func completeOnboarding(categories: [String], currentDescription: String, goalDescription: String) async throws {
        guard let token = token else { throw APIError.unauthorized }
        isLoading = true; defer { isLoading = false }
        _ = try await APIClient.shared.setupOnboarding(
            token: token,
            categories: categories,
            currentDescription: currentDescription,
            goalDescription: goalDescription
        )
        let profile = try await APIClient.shared.getProfile(token: token)
        self.profile = profile
        self.isOnboarded = true
    }

    func refreshProfile() async throws {
        guard let token = token else { throw APIError.unauthorized }
        self.profile = try await APIClient.shared.getProfile(token: token)
    }

    func completeTask(category: String, task: String, image: UIImage? = nil) async throws -> CompleteTaskResponse {
        guard let token = token else { throw APIError.unauthorized }
        
        print("🔄 AppState.completeTask called")
        print("   Category: \(category)")
        print("   Task: \(task)")
        print("   Image: \(image != nil ? "Provided" : "None")")
        
        var imageBase64: String?
        if let image = image {
            print("📸 Processing image for upload...")
            print("   Original size: \(image.size)")
            
            imageBase64 = ImageUtilities.prepareImageForUpload(
                image: image, maxDimension: 1024, compressionQuality: 0.7
            )
            
            if let base64 = imageBase64 {
                let sizeKB = base64.count / 1024
                print("✅ Image converted to base64: \(sizeKB) KB")
            } else {
                print("⚠️ Image conversion failed!")
            }
        } else {
            print("⚠️ No image provided to backend")
        }
        
        print("🌐 Sending request to backend...")
        let response = try await APIClient.shared.completeTask(
            token: token, category: category, task: task, imageBase64: imageBase64
        )
        
        print("✅ Backend response received:")
        print("   Score: \(response.score)")
        print("   Feedback: \(response.feedback)")
        
        // Store AI score for end-of-day summary
        dailyTaskScores[category] = response.score
        
        print("🔄 Refreshing profile...")
        try await refreshProfile()
        print("✅ Profile refreshed successfully")
        
        return response
    }

    var selectedCategories: [String] {
        profile?.todays_tasks.keys.map { $0 } ?? []
    }
}
