//
//  HomeView.swift
//  ditto-hacks
//
//  Main screen showing all 3 clones and competition status
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showTasks = false
    @State private var showProgress = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let profile = appState.profile {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Header
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Welcome back,")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text(profile.user.username)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                NavigationLink(destination: ProfileView()) {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 60)
                            
                            // 3 Clones Display
                            ThreeClonesView(profile: profile)
                                .padding(.horizontal, 16)
                            
                            // Competition Banner
                            CompetitionBanner(competition: profile.competition)
                                .padding(.horizontal, 20)
                            
                            // Streak & Stats
                            StreakCard(streak: profile.streak)
                                .padding(.horizontal, 20)
                            
                            // Quick Actions
                            HStack(spacing: 12) {
                                NavigationLink(destination: TasksView()) {
                                    QuickActionCard(
                                        title: "Today's Tasks",
                                        subtitle: "\(profile.todays_tasks.count) tasks",
                                        icon: "checklist",
                                        color: Color(red: 0.0, green: 0.9, blue: 0.4)
                                    )
                                }
                                
                                NavigationLink(destination: DetailedProgressView()) {
                                    QuickActionCard(
                                        title: "Progress",
                                        subtitle: "View gaps",
                                        icon: "chart.bar.fill",
                                        color: .blue
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                    .refreshable {
                        await refreshData()
                    }
                } else {
                    SwiftUI.ProgressView()
                        .tint(.white)
                }
            }
        }
        .task {
            await refreshData()
        }
    }
    
    private func refreshData() async {
        do {
            try await appState.refreshProfile()
        } catch {
            print("Failed to refresh profile: \(error)")
        }
    }
}

// MARK: - Three Clones View
struct ThreeClonesView: View {
    let profile: ProfileResponse
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Your Clones")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
            
            HStack(spacing: 12) {
                ClonePlaceholder(
                    label: "YOU",
                    color: .blue,
                    morphValues: profile.you
                )
                
                ClonePlaceholder(
                    label: "AI CLONE",
                    color: .red,
                    morphValues: profile.ai_nemesis
                )
                
                ClonePlaceholder(
                    label: "IDEAL SELF",
                    color: .yellow,
                    morphValues: profile.ideal_self
                )
            }
        }
    }
}

struct ClonePlaceholder: View {
    let label: String
    let color: Color
    let morphValues: AvatarMorphValues
    
    var overallScore: Float {
        morphValues.average()
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // 3D Model Viewer
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.06, green: 0.06, blue: 0.09))
                .frame(height: 160)
                .overlay(
                    AvatarSceneView(score: overallScore)
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
            
            // Label
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
            
            // Progress bar
            VStack(spacing: 4) {
                SwiftUI.ProgressView(value: Double(overallScore))
                    .tint(color)
                
                Text(String(format: "%.0f%%", overallScore * 100))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Competition Banner
struct CompetitionBanner: View {
    let competition: CompetitionStatus
    
    var isWinning: Bool {
        competition.status == "winning"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isWinning ? "trophy.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 24))
                .foregroundColor(isWinning ? .yellow : .red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isWinning ? "You're Winning!" : "AI Clone is Ahead!")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                
                Text(competition.message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isWinning ?
                      Color.yellow.opacity(0.15) :
                      Color.red.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isWinning ? Color.yellow.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Streak Card
struct StreakCard: View {
    let streak: StreakInfo
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("\(streak.days)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                Text("Day Streak")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 1, height: 50)
            
            VStack(spacing: 4) {
                Text("\(streak.habits_today)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.blue)
                Text("Habits Today")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
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

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState.shared)
}
