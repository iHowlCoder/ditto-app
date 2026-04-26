//
//  TasksView.swift
//  ditto-hacks
//
//  Today's tasks with photo verification
//

import SwiftUI

struct TasksView: View {
    @EnvironmentObject var appState: AppState

    // Which tasks the user has submitted this session
    @State private var completedTasks: Set<String> = []

    // Photo capture sheet
    @State private var showPhotoCapture = false
    @State private var selectedTask: (category: String, task: String)?

    // Loading overlay while API call is in flight
    @State private var isSubmitting = false

    // Score feedback sheet — shown AFTER API returns
    @State private var showFeedback = false
    @State private var feedbackScore: Float = 0.0
    @State private var feedbackMessage = ""
    @State private var feedbackCategory = ""
    @State private var feedbackTask = ""

    // Animated bar progress: 0.0 – 1.0
    // Each completed task adds exactly (1 / totalCount) to this value.
    @State private var barProgress: Double = 0.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let profile = appState.profile {
                let totalCount = profile.todays_tasks.count

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // ── Header ──────────────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today's Tasks")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("Complete tasks to train your AI Clone")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // ── Progress card ────────────────────────────────
                        VStack(spacing: 12) {
                            HStack {
                                Text("Today's Progress")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(completedTasks.count) of \(totalCount) completed")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                    Text("\(Int(barProgress * 100))%")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }

                            // Segmented bar: N equal slots, each fills when task done
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    // Track
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.07))
                                        .frame(height: 12)

                                    // Fill — width driven by barProgress
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.0, green: 0.7, blue: 0.3),
                                                    Color(red: 0.0, green: 0.9, blue: 0.4)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: max(0, geo.size.width * CGFloat(barProgress)),
                                            height: 12
                                        )
                                        .animation(
                                            .spring(response: 0.65, dampingFraction: 0.72),
                                            value: barProgress
                                        )
                                }
                            }
                            .frame(height: 12)
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
                        .padding(.horizontal, 20)
                        // Sync bar whenever completedTasks changes
                        .onChange(of: completedTasks) { newValue in
                            let newProgress = totalCount > 0
                                ? Double(newValue.count) / Double(totalCount)
                                : 0
                            print("🔄 Progress bar updating...")
                            print("   Completed tasks: \(newValue.count)")
                            print("   Total tasks: \(totalCount)")
                            print("   New progress: \(newProgress)")
                            withAnimation {
                                barProgress = newProgress
                            }
                        }
                        .onAppear {
                            let initialProgress = totalCount > 0
                                ? Double(completedTasks.count) / Double(totalCount)
                                : 0
                            print("📊 Initial progress: \(initialProgress)")
                            barProgress = initialProgress
                        }

                        // ── Task list ────────────────────────────────────
                        VStack(spacing: 12) {
                            ForEach(
                                Array(profile.todays_tasks.sorted(by: { $0.key < $1.key })),
                                id: \.key
                            ) { category, task in
                                TaskRow(
                                    category: category,
                                    task: task,
                                    isCompleted: completedTasks.contains(category),
                                    score: appState.dailyTaskScores[category],
                                    onTap: {
                                        selectedTask = (category, task)
                                        showPhotoCapture = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            } else {
                SwiftUI.ProgressView()
                    .tint(.white)
            }

            // ── Analysing overlay ────────────────────────────────────────
            if isSubmitting {
                ZStack {
                    Color.black.opacity(0.75).ignoresSafeArea()
                    VStack(spacing: 16) {
                        SwiftUI.ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        Text("Analyzing photo…")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(32)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(white: 0.15)))
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)

        // ── Photo capture sheet ──────────────────────────────────────────
        .sheet(isPresented: $showPhotoCapture) {
            if let task = selectedTask {
                PhotoCaptureView(
                    category: task.category,
                    task: task.task,
                    onComplete: { image in
                        showPhotoCapture = false
                        Task {
                            await submitTask(
                                category: task.category,
                                task: task.task,
                                image: image
                            )
                        }
                    },
                    onCancel: {
                        showPhotoCapture = false
                        selectedTask = nil
                    }
                )
            }
        }

        // ── Score feedback sheet — shown after API returns ───────────────
        .sheet(isPresented: $showFeedback) {
            ScoreFeedbackView(
                score: feedbackScore,
                feedback: feedbackMessage,
                category: feedbackCategory,
                task: feedbackTask,
                onDismiss: {
                    showFeedback = false
                    // Mark task completed and animate bar AFTER user
                    // has seen their score and taps Continue.
                    withAnimation(.spring(response: 0.65, dampingFraction: 0.72)) {
                        completedTasks.insert(feedbackCategory)
                    }
                    print("✅ Task completed: \(feedbackCategory)")
                    print("📊 Total completed: \(completedTasks.count)")
                    print("📈 Progress: \(barProgress)")
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Submit

    private func submitTask(category: String, task: String, image: UIImage? = nil) async {
        print("📤 Submitting task: \(category)")
        print("🖼️ Image provided: \(image != nil ? "Yes (\(image!.size))" : "No")")
        
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let response = try await appState.completeTask(
                category: category,
                task: task,
                image: image
            )
            
            print("✅ Backend response received:")
            print("   Score: \(response.score)")
            print("   Feedback: \(response.feedback)")
            print("   Category: \(response.category)")
            
            // Populate feedback state, then show the sheet
            feedbackScore    = response.score
            feedbackMessage  = response.feedback
            feedbackCategory = category
            feedbackTask     = task
            
            // Show feedback sheet on main thread
            await MainActor.run {
                showFeedback = true
            }
        } catch {
            print("❌ Failed to complete task: \(error)")
            print("   Error details: \(error.localizedDescription)")
        }
    }
}

// MARK: - TaskRow

struct TaskRow: View {
    let category: String
    let task: String
    let isCompleted: Bool
    let score: Float?   // nil until submitted
    let onTap: () -> Void

    var categoryIcon: String {
        switch category {
        case "sleep":       return "moon.fill"
        case "physique":    return "figure.run"
        case "water":       return "drop.fill"
        case "nutrition":   return "leaf.fill"
        case "mood":        return "heart.fill"
        case "school":      return "book.fill"
        case "work":        return "briefcase.fill"
        case "mindfulness": return "brain.head.profile"
        case "screentime":  return "iphone"
        case "social":      return "person.2.fill"
        default:            return "circle.fill"
        }
    }

    private let green = Color(red: 0.0, green: 0.9, blue: 0.4)

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(isCompleted ? green.opacity(0.2) : Color.white.opacity(0.08))
                        .frame(width: 44, height: 44)
                    Image(systemName: categoryIcon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isCompleted ? green : .white.opacity(0.6))
                }

                // Task text
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.capitalized)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(green)
                    Text(task)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // Trailing: score badge if done, camera if not
                if isCompleted, let score = score {
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(green)
                        Text("\(Int(score * 100))%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(green)
                    }
                } else {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isCompleted ? green.opacity(0.08) : Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isCompleted ? green.opacity(0.3) : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isCompleted)
    }
}

// MARK: - ScoreFeedbackView

struct ScoreFeedbackView: View {
    let score: Float
    let feedback: String
    let category: String
    let task: String
    let onDismiss: () -> Void

    private var percentage: Int { Int(score * 100) }

    private var scoreEmoji: String {
        switch percentage {
        case 95...100: return "🌟"
        case 85..<95:  return "💪"
        case 70..<85:  return "👍"
        case 50..<70:  return "📈"
        default:       return "🎯"
        }
    }

    private var scoreTitle: String {
        switch percentage {
        case 95...100: return "Perfect Execution!"
        case 85..<95:  return "Excellent Work!"
        case 70..<85:  return "Great Effort!"
        case 50..<70:  return "Good Progress!"
        default:       return "Keep Pushing!"
        }
    }

    private var starCount: Int {
        switch percentage {
        case 95...100: return 5
        case 85..<95:  return 4
        case 70..<85:  return 3
        case 50..<70:  return 2
        default:       return 1
        }
    }

    private var scoreColor: Color {
        switch percentage {
        case 80...100: return Color(red: 0.0, green: 0.9, blue: 0.4)
        case 50..<80:  return .blue
        default:       return .orange
        }
    }

    private var motivationalMessage: String {
        switch percentage {
        case 90...100: return "Your AI Clone is learning from your excellence! 🚀"
        case 75..<90:  return "Your AI Clone is growing stronger with each task! 💪"
        case 60..<75:  return "Your AI Clone is picking up everything you bring! 📚"
        case 40..<60:  return "Every step you take teaches your AI Clone something new! ⬆️"
        default:       return "Give it another shot — your AI Clone is counting on you! 🎯"
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // Score ring
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 12)
                            .frame(width: 160, height: 160)
                        Circle()
                            .trim(from: 0, to: CGFloat(score))
                            .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .frame(width: 160, height: 160)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut(duration: 0.8), value: score)
                        VStack(spacing: 4) {
                            Text(scoreEmoji).font(.system(size: 36))
                            Text("\(percentage)%")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 32)

                    // Title + stars
                    VStack(spacing: 10) {
                        Text(scoreTitle)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        HStack(spacing: 6) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= starCount ? "star.fill" : "star")
                                    .font(.system(size: 22))
                                    .foregroundColor(
                                        i <= starCount ? scoreColor : Color.white.opacity(0.2)
                                    )
                            }
                        }
                        Text(category.capitalized)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(scoreColor)
                            .padding(.horizontal, 14).padding(.vertical, 5)
                            .background(scoreColor.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    // AI Feedback box
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "brain")
                                .font(.system(size: 16))
                                .foregroundColor(scoreColor)
                            Text("AI Feedback")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Text(feedback.isEmpty ? "Nice work submitting this task!" : feedback)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white.opacity(0.85))
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(scoreColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)

                    // Score breakdown
                    VStack(spacing: 14) {
                        ScoreBreakdownRow(label: "Completion",  value: min(score + 0.05, 1.0), color: scoreColor)
                        ScoreBreakdownRow(label: "Quality",     value: score,                  color: scoreColor)
                        ScoreBreakdownRow(label: "Consistency", value: max(score - 0.08, 0),   color: scoreColor)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)

                    Text(motivationalMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    // Continue — triggers bar animation in parent
                    Button(action: onDismiss) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(scoreColor)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - ScoreBreakdownRow

struct ScoreBreakdownRow: View {
    let label: String
    let value: Float
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 90, alignment: .leading)
            ProgressView(value: Double(value))
                .tint(color)
            Text("\(Int(value * 100))%")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 38, alignment: .trailing)
        }
    }
}

#Preview {
    NavigationStack {
        TasksView()
            .environmentObject(AppState.shared)
    }
}
