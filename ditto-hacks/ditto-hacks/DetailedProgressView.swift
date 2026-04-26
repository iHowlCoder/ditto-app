//
//  DetailedProgressView.swift
//  ditto-hacks
//
//  Detailed gap analysis and progress tracking
//

import SwiftUI

struct DetailedProgressView: View {
    @EnvironmentObject var appState: AppState
    @State private var gapAnalysis: DetailedGapAnalysis?
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Progress")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Track your journey to your ideal self")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    if let profile = appState.profile {
                        // Overall Scores
                        HStack(spacing: 12) {
                            ScoreCard(
                                title: "YOU",
                                score: profile.you.average(),
                                color: .blue
                            )
                            
                            ScoreCard(
                                title: "AI CLONE",
                                score: profile.ai_nemesis.average(),
                                color: .red
                            )
                            
                            ScoreCard(
                                title: "IDEAL",
                                score: profile.ideal_self.average(),
                                color: .yellow
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Gap vs Ideal Self
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Gap vs Ideal Self")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                ForEach(Array(profile.gap_vs_ideal.by_category.sorted(by: { $0.key < $1.key })), id: \.key) { category, gap in
                                    GapRow(
                                        category: category,
                                        current: getCategoryValue(category: category, from: profile.you),
                                        target: getCategoryValue(category: category, from: profile.ideal_self),
                                        gap: gap
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Focus Message
                        if !profile.gap_vs_ideal.focus_message.isEmpty {
                            HStack(spacing: 12) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.yellow)
                                
                                Text(profile.gap_vs_ideal.focus_message)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.yellow.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Competition Details (if we have gap analysis)
                        if let analysis = gapAnalysis {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Competition Status")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 12) {
                                    ForEach(Array(analysis.gap_vs_ai_nemesis.sorted(by: { $0.key < $1.key })), id: \.key) { category, aiGap in
                                        AICompetitionRow(
                                            category: category,
                                            you: aiGap.you,
                                            aiNemesis: aiGap.ai_nemesis,
                                            status: aiGap.status
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .refreshable {
                await loadGapAnalysis()
            }
            
            if isLoading {
                SwiftUI.ProgressView()
                    .tint(.white)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadGapAnalysis()
        }
    }
    
    private func loadGapAnalysis() async {
        guard let token = appState.token else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            gapAnalysis = try await APIClient.shared.getGapAnalysis(token: token)
        } catch {
            print("Failed to load gap analysis: \(error)")
        }
    }
    
    private func getCategoryValue(category: String, from morphValues: AvatarMorphValues) -> Float {
        switch category {
        case "sleep": return morphValues.sleep
        case "physique": return morphValues.physique
        case "water": return morphValues.water
        case "nutrition": return morphValues.nutrition
        case "mood": return morphValues.mood
        case "school": return morphValues.school
        case "work": return morphValues.work
        case "mindfulness": return morphValues.mindfulness
        case "screentime": return morphValues.screentime
        case "social": return morphValues.social
        default: return 0.0
        }
    }
}

// MARK: - Score Card
struct ScoreCard: View {
    let title: String
    let score: Float
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
            
            Text(String(format: "%.0f%%", score * 100))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            
            SwiftUI.ProgressView(value: Double(score))
                .tint(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Gap Row
struct GapRow: View {
    let category: String
    let current: Float
    let target: Float
    let gap: Float
    
    var percentageClosed: Float {
        current / target
    }
    
    var categoryIcon: String {
        switch category {
        case "sleep": return "moon.fill"
        case "physique": return "figure.run"
        case "water": return "drop.fill"
        case "nutrition": return "leaf.fill"
        case "mood": return "heart.fill"
        case "school": return "book.fill"
        case "work": return "briefcase.fill"
        case "mindfulness": return "brain.head.profile"
        case "screentime": return "iphone"
        case "social": return "person.2.fill"
        default: return "circle.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: categoryIcon)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                    .frame(width: 20)
                
                Text(category.capitalized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "%.0f%% / %.0f%%", current * 100, target * 100))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background (target)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                    
                    // Progress (current)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.0, green: 0.9, blue: 0.4))
                        .frame(width: geo.size.width * CGFloat(percentageClosed))
                }
            }
            .frame(height: 8)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - AI Competition Row
struct AICompetitionRow: View {
    let category: String
    let you: Float
    let aiNemesis: Float
    let status: String
    
    var isWinning: Bool {
        status == "winning"
    }
    
    var categoryIcon: String {
        switch category {
        case "sleep": return "moon.fill"
        case "physique": return "figure.run"
        case "water": return "drop.fill"
        case "nutrition": return "leaf.fill"
        case "mood": return "heart.fill"
        case "school": return "book.fill"
        case "work": return "briefcase.fill"
        case "mindfulness": return "brain.head.profile"
        case "screentime": return "iphone"
        case "social": return "person.2.fill"
        default: return "circle.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: categoryIcon)
                    .font(.system(size: 14))
                    .foregroundColor(isWinning ? .blue : .red)
                    .frame(width: 20)
                
                Text(category.capitalized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: isWinning ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(isWinning ? Color(red: 0.0, green: 0.9, blue: 0.4) : .red)
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("You")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.0f%%", you * 100))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.blue)
                }
                
                Text("vs")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Clone")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.0f%%", aiNemesis * 100))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isWinning ?
                      Color.blue.opacity(0.08) :
                      Color.red.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isWinning ?
                            Color.blue.opacity(0.2) :
                            Color.red.opacity(0.2),
                            lineWidth: 1
                        )
                )
        )
    }
}

#Preview {
    NavigationStack {
        DetailedProgressView()
            .environmentObject(AppState.shared)
    }
}
