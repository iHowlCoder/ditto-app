//
//  APIClient.swift
//  ditto-hacks
//
//  Network layer for Ditto backend
//

import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
    case unauthorized
}

class APIClient {
    static let shared = APIClient()
    private let baseURL = "https://hackathon-ditto-backend.onrender.com"
    
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0  // 10 second timeout
        config.timeoutIntervalForResource = 30.0 // 30 second total timeout
        return URLSession(configuration: config)
    }()
    
    private init() {}
    
    // MARK: - Auth Endpoints
    
    func register(email: String, username: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = RegisterRequest(email: email, username: username, password: password)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = LoginRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
    
    // MARK: - Profile Endpoints
    
    func getProfile(token: String) async throws -> ProfileResponse {
        guard let url = URL(string: "\(baseURL)/profile/?token=\(token)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        return try JSONDecoder().decode(ProfileResponse.self, from: data)
    }
    
    // MARK: - Onboarding Endpoints
    
    func setupOnboarding(token: String, categories: [String], currentDescription: String, goalDescription: String) async throws -> OnboardingSetupResponse {
        guard let url = URL(string: "\(baseURL)/onboarding/setup?token=\(token)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = OnboardingSetupRequest(
            categories: categories,
            current_description: currentDescription,
            goal_description: goalDescription
        )
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(OnboardingSetupResponse.self, from: data)
    }
    
    func getOnboardingStatus(token: String) async throws -> OnboardingStatusResponse {
        guard let url = URL(string: "\(baseURL)/onboarding/status?token=\(token)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(OnboardingStatusResponse.self, from: data)
    }
    
    // MARK: - Task Endpoints
    
    func getCategories() async throws -> CategoriesResponse {
        guard let url = URL(string: "\(baseURL)/tasks/categories") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(CategoriesResponse.self, from: data)
    }
    
    func generateDailyTasks(token: String, categories: [String]) async throws -> GenerateTasksResponse {
        guard let url = URL(string: "\(baseURL)/tasks/generate?token=\(token)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = GenerateTasksRequest(categories: categories)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(GenerateTasksResponse.self, from: data)
    }
    
    func completeTask(token: String, category: String, task: String, imageBase64: String? = nil) async throws -> CompleteTaskResponse {
        guard let url = URL(string: "\(baseURL)/tasks/complete?token=\(token)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = CompleteTaskRequest(category: category, task: task, image_base64: imageBase64)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(CompleteTaskResponse.self, from: data)
    }
    
    // MARK: - Habit Endpoints
    
    func logHabit(token: String, category: String, description: String) async throws -> LogHabitResponse {
        guard let url = URL(string: "\(baseURL)/habits/log?token=\(token)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = LogHabitRequest(category: category, description: description)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(LogHabitResponse.self, from: data)
    }
    
    // MARK: - AI Clone Endpoints
    
    func getAINemesisStatus(token: String) async throws -> AINemesisStatusResponse {
        guard let url = URL(string: "\(baseURL)/ai-clone/status?token=\(token)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(AINemesisStatusResponse.self, from: data)
    }
    
    // MARK: - Streak Endpoints
    
    func getStreakStatus(token: String) async throws -> StreakStatusResponse {
        guard let url = URL(string: "\(baseURL)/streak/status?token=\(token)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(StreakStatusResponse.self, from: data)
    }
    
    func getHabitHistory(token: String) async throws -> HabitHistoryResponse {
        guard let url = URL(string: "\(baseURL)/streak/history?token=\(token)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(HabitHistoryResponse.self, from: data)
    }
    
    // MARK: - Gap Analysis Endpoints
    
    func getGapAnalysis(token: String) async throws -> DetailedGapAnalysis {
        guard let url = URL(string: "\(baseURL)/gap/analysis?token=\(token)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(DetailedGapAnalysis.self, from: data)
    }
}
