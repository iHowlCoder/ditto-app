//
//  Models.swift
//  ditto-hacks
//
//  Backend response models
//

import Foundation

// MARK: - Auth Models
struct AuthResponse: Codable {
    let token: String
    let user_id: Int
    let username: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let username: String
    let password: String
}

// MARK: - Profile Models
struct ProfileResponse: Codable {
    let user: UserInfo
    let streak: StreakInfo
    let you: AvatarMorphValues
    let ideal_self: AvatarMorphValues
    let ai_nemesis: AvatarMorphValues
    let competition: CompetitionStatus
    let gap_vs_ideal: GapAnalysis
    let todays_tasks: [String: String]
    let onboarded: Bool
}

struct UserInfo: Codable {
    let id: Int
    let username: String
    let email: String
    let member_since: String
}

struct StreakInfo: Codable {
    let days: Int
    let habits_today: Int
    let message: String
}

struct AvatarMorphValues: Codable {
    let sleep: Float
    let physique: Float
    let water: Float
    let nutrition: Float
    let mood: Float
    let school: Float
    let work: Float
    let mindfulness: Float
    let screentime: Float
    let social: Float
    
    func toArray() -> [Float] {
        return [sleep, physique, water, nutrition, mood, school, work, mindfulness, screentime, social]
    }
    
    func average() -> Float {
        let values = toArray()
        return values.reduce(0, +) / Float(values.count)
    }
}

struct CompetitionStatus: Codable {
    let status: String // "winning" or "losing"
    let you_average: Float
    let ai_average: Float
    let message: String
}

struct GapAnalysis: Codable {
    let by_category: [String: Float]
    let overall: Float
    let biggest_gap: String
    let focus_message: String
}

// MARK: - Onboarding Models
struct OnboardingSetupRequest: Codable {
    let categories: [String]
    let current_description: String
    let goal_description: String
}

struct OnboardingSetupResponse: Codable {
    let message: String
    let selected_categories: [String]
    let you: AvatarMorphValues
    let ideal_self: AvatarMorphValues
    let ai_nemesis: AvatarMorphValues
    let gap_vs_ideal: [String: Float]
}

struct OnboardingStatusResponse: Codable {
    let onboarded: Bool
    let you: AvatarMorphValues
    let ideal_self: AvatarMorphValues
    let ai_nemesis: AvatarMorphValues
}

// MARK: - Task Models
struct CategoriesResponse: Codable {
    let categories: [String]
    let total: Int
}

struct GenerateTasksRequest: Codable {
    let categories: [String]
}

struct GenerateTasksResponse: Codable {
    let user_id: Int
    let tasks: [String: String]
    let total: Int
}

struct CompleteTaskRequest: Codable {
    let category: String
    let task: String
    let image_base64: String?  // Optional base64 encoded image
}

struct CompleteTaskResponse: Codable {
    let message: String
    let category: String
    let task: String
    let score: Float
    let feedback: String
}

// MARK: - Habit Models
struct LogHabitRequest: Codable {
    let category: String
    let description: String
}

struct LogHabitResponse: Codable {
    let message: String
    let category: String
    let score: Float
    let feedback: String
    let avatar_updated: String
}

// MARK: - AI Clone Models
struct AINemesisStatusResponse: Codable {
    let ai_nemesis: AvatarMorphValues
    let last_grown: String
    let daily_growth_rate: Float
    let message: String
}

// MARK: - Streak Models
struct StreakStatusResponse: Codable {
    let streak: Int
    let total_habits_logged: Int
    let habits_logged_today: Int
    let message: String
}

struct HabitHistoryEntry: Codable {
    let date: String
    let category: String
    let score: Float
    let description: String
}

struct HabitHistoryResponse: Codable {
    let last_7_days: [HabitHistoryEntry]
    let total: Int
}

// MARK: - Gap Analysis Models
struct DetailedGapAnalysis: Codable {
    let you_overall: Float
    let ideal_overall: Float
    let ai_nemesis_overall: Float
    let gap_vs_ideal: [String: GapDetail]
    let gap_vs_ai_nemesis: [String: AIGapDetail]
    let competition: DetailedCompetition
}

struct GapDetail: Codable {
    let current: Float
    let target: Float
    let gap: Float
    let percentage_closed: Float
}

struct AIGapDetail: Codable {
    let you: Float
    let ai_nemesis: Float
    let difference: Float
    let status: String // "winning" or "losing"
}

struct DetailedCompetition: Codable {
    let status: String
    let overall_difference: Float
    let winning_categories: [String]
    let losing_categories: [String]
    let message: String
}
