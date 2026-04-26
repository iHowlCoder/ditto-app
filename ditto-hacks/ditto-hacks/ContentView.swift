//
//  ContentView.swift
//  ditto-hackathon
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showStats = false
    @State private var checkedItems: Set<Int> = []
    @State private var isLoading = false

    // Get habits from backend profile
    var habits: [(String, String, String)] {
        guard let profile = appState.profile else {
            // Fallback to demo data if no profile
            return [
                ("Sleep", "moon.fill", "7–9 hours"),
                ("Workout", "figure.run", "30+ minutes"),
                ("Water", "drop.fill", "8 glasses"),
                ("Nutrition", "leaf.fill", "Balanced meals"),
                ("Meditation", "heart.fill", "10 minutes"),
                ("Steps", "figure.walk", "10,000 steps"),
                ("Screen Time", "iphone", "Under 2 hours"),
                ("Reading", "book.fill", "20 minutes"),
                ("Cold Shower", "snowflake", "2 minutes"),
                ("Journal", "pencil", "5 minutes")
            ]
        }
        
        // Convert backend tasks to display format
        return profile.todays_tasks.map { (category, task) in
            let icon = categoryIcon(for: category)
            return (category.capitalized, icon, task)
        }
    }

    var completedCount: Int { 
        appState.profile?.streak.habits_today ?? checkedItems.count 
    }
    var totalCount: Int { habits.count }
    var progress: Double { 
        if let profile = appState.profile {
            return Double(profile.you.average())
        }
        return totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0 
    }
    
    // Map category names to SF Symbols
    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "sleep": return "moon.fill"
        case "physique", "workout": return "figure.run"
        case "water": return "drop.fill"
        case "nutrition": return "leaf.fill"
        case "mood", "meditation": return "heart.fill"
        case "school": return "book.fill"
        case "work": return "briefcase.fill"
        case "mindfulness": return "brain.head.profile"
        case "screentime": return "iphone"
        case "social": return "person.2.fill"
        default: return "checkmark.circle.fill"
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // MARK: - Header
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Today")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Text(formattedDate())
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        Spacer()

                        // Progress ring badge
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.08), lineWidth: 3)
                                .frame(width: 46, height: 46)
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    Color(red: 0.0, green: 0.9, blue: 0.4),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                )
                                .frame(width: 46, height: 46)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(), value: progress)
                            Text("\(completedCount)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 20)

                    // MARK: - 3D Avatar Viewport
                    ZStack(alignment: .bottom) {
                        // MARK: - 3D SECTION — FILLED PER INSTRUCTION
                        AvatarSceneView(score: Float(progress))
                            .frame(height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 24))

                        // Top fade overlay
                        VStack {
                            LinearGradient(
                                colors: [.black.opacity(0.5), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            Spacer()
                        }

                        // Current / Ideal labels
                        HStack {
                            Text("Current")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(.ultraThinMaterial))

                            Spacer()

                            Text("Ideal")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(.ultraThinMaterial))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 16)

                    // MARK: - Stats Dropdown
                    VStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showStats.toggle()
                            }
                        }) {
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                    Text("Statistics")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Image(systemName: showStats ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.35))
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 15)
                        }
                        .buttonStyle(PlainButtonStyle())

                        if showStats {
                            VStack(spacing: 12) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.07))
                                    .frame(height: 1)
                                    .padding(.horizontal, 18)

                                HStack(spacing: 10) {
                                    MiniStatCard(label: "Score", value: "\(completedCount)/\(totalCount)", isGreen: true)
                                    MiniStatCard(label: "Streak", value: "3 days", isGreen: false)
                                    MiniStatCard(label: "Best", value: "12 days", isGreen: false)
                                }
                                .padding(.horizontal, 14)

                                VStack(alignment: .leading, spacing: 7) {
                                    HStack {
                                        Text("Daily completion")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.38))
                                        Spacer()
                                        Text("\(Int(progress * 100))%")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                    }
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(Color.white.opacity(0.07))
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(Color(red: 0.0, green: 0.9, blue: 0.4))
                                                .frame(width: geo.size.width * progress)
                                                .animation(.spring(), value: progress)
                                        }
                                        .frame(height: 6)
                                    }
                                    .frame(height: 6)
                                }
                                .padding(.horizontal, 18)
                                .padding(.bottom, 14)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 14)

                    // MARK: - Habits Section
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Habits")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(completedCount) of \(totalCount) done")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 28)
                        .padding(.bottom, 14)

                        VStack(spacing: 8) {
                            ForEach(0..<habits.count, id: \.self) { index in
                                HabitRow(
                                    icon: habits[index].1,
                                    title: habits[index].0,
                                    subtitle: habits[index].2,
                                    isChecked: checkedItems.contains(index),
                                    action: { 
                                        completeHabit(at: index) 
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 50)
                    }
                }
            }
            .refreshable {
                await refreshData()
            }
            
            // Loading overlay
            if isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                    .scaleEffect(1.5)
            }
        }
        .task {
            // Load profile on appear if not loaded
            if appState.profile == nil {
                await refreshData()
            }
        }
    }

    // MARK: - Helpers
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    // MARK: - Backend Integration
    func completeHabit(at index: Int) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            if checkedItems.contains(index) {
                // Toggle off - just local state
                checkedItems.remove(index)
            } else {
                // Toggle on - send to backend
                checkedItems.insert(index)
                
                guard let profile = appState.profile else { return }
                
                let habit = habits[index]
                let category = habit.0.lowercased()
                let task = habit.2
                
                isLoading = true
                
                Task {
                    do {
                        // Send to backend
                        let response = try await appState.completeTask(
                            category: category,
                            task: task,
                            image: nil
                        )
                        
                        print("✅ Task completed! Score: \(response.score)")
                        print("📝 Feedback: \(response.feedback)")
                        
                        // Refresh profile to get updated avatar values
                        try await appState.refreshProfile()
                        
                    } catch {
                        print("❌ Failed to complete task: \(error)")
                        // Revert on error
                        await MainActor.run {
                            withAnimation {
                                checkedItems.remove(index)
                            }
                        }
                    }
                    
                    await MainActor.run {
                        isLoading = false
                    }
                }
            }
        }
    }
    
    func refreshData() async {
        do {
            try await appState.refreshProfile()
        } catch {
            print("❌ Failed to refresh: \(error)")
        }
    }
}

// MARK: - MiniStatCard
struct MiniStatCard: View {
    let label: String
    let value: String
    let isGreen: Bool

    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(isGreen ? Color(red: 0.0, green: 0.9, blue: 0.4) : .white)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.32))
                .textCase(.uppercase)
                .tracking(0.4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.04))
        )
    }
}

// MARK: - HabitRow
struct HabitRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isChecked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isChecked
                              ? Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.14)
                              : Color.white.opacity(0.05))
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isChecked
                                         ? Color(red: 0.0, green: 0.9, blue: 0.4)
                                         : .white.opacity(0.4))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.28))
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(
                            isChecked ? Color.clear : Color.white.opacity(0.16),
                            lineWidth: 1.5
                        )
                        .frame(width: 26, height: 26)

                    if isChecked {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color(red: 0.0, green: 0.9, blue: 0.4))
                            .frame(width: 26, height: 26)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isChecked
                          ? Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.06)
                          : Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isChecked
                                ? Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.18)
                                : Color.white.opacity(0.06),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
