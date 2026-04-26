//
//  DayScoreView.swift
//  ditto-hacks
//
//  End-of-day score summary screen
//

import SwiftUI

struct DayScoreView: View {
    let taskScores: [String: Float]   // category -> AI score (absent = not submitted = 0%)
    let totalTasks: [String: String]  // category -> task description
    let onDismiss: () -> Void

    private var averageScore: Float {
        guard !totalTasks.isEmpty else { return 0 }
        let sum = totalTasks.keys.reduce(Float(0)) { $0 + (taskScores[$1] ?? 0.0) }
        return sum / Float(totalTasks.count)
    }

    private var percentage: Int { Int(averageScore * 100) }

    private var scoreColor: Color {
        switch percentage {
        case 80...100: return Color(red: 0.0, green: 0.9, blue: 0.4)
        case 50..<80:  return .blue
        default:       return .orange
        }
    }

    private var scoreTitle: String {
        switch percentage {
        case 90...100: return "Legendary Day! 🌟"
        case 75..<90:  return "Excellent Day! 💪"
        case 60..<75:  return "Solid Effort! 👍"
        case 40..<60:  return "Good Start! 📈"
        default:       return "Keep Going! 🎯"
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    VStack(spacing: 6) {
                        Text("Day Complete")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                            .textCase(.uppercase).tracking(1.5)
                        Text("Daily Score")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)

                    // Score ring
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 14)
                            .frame(width: 180, height: 180)
                        Circle()
                            .trim(from: 0, to: CGFloat(averageScore))
                            .stroke(scoreColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                            .frame(width: 180, height: 180)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut(duration: 1.0), value: averageScore)
                        VStack(spacing: 4) {
                            Text("\(percentage)%")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text(scoreTitle)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(scoreColor)
                                .multilineTextAlignment(.center)
                        }
                    }

                    // Task breakdown
                    VStack(spacing: 10) {
                        HStack {
                            Text("Task Breakdown")
                                .font(.system(size: 17, weight: .bold)).foregroundColor(.white)
                            Spacer()
                            Text("\(taskScores.values.filter { $0 > 0 }.count)/\(totalTasks.count) completed")
                                .font(.system(size: 13, weight: .medium)).foregroundColor(.white.opacity(0.5))
                        }

                        ForEach(Array(totalTasks.keys.sorted()), id: \.self) { category in
                            let score = taskScores[category] ?? 0.0
                            let completed = score > 0

                            HStack(spacing: 12) {
                                Image(systemName: completed ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(completed ? scoreColor : .red.opacity(0.7))
                                    .frame(width: 24)

                                Text(category.capitalized)
                                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                    .frame(width: 90, alignment: .leading)

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.07))
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(completed ? scoreColor : Color.red.opacity(0.4))
                                            .frame(width: geo.size.width * CGFloat(score))
                                            .animation(.easeOut(duration: 0.8), value: score)
                                    }
                                    .frame(height: 6)
                                }
                                .frame(height: 6)

                                Text(completed ? "\(Int(score * 100))%" : "0%")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(completed ? scoreColor : .red.opacity(0.7))
                                    .frame(width: 34, alignment: .trailing)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04))
                                    .overlay(RoundedRectangle(cornerRadius: 12)
                                        .stroke(completed ? scoreColor.opacity(0.2) : Color.red.opacity(0.15),
                                                lineWidth: 1))
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    Text("Score = average of all tasks (0% for skipped)")
                        .font(.system(size: 12)).foregroundColor(.white.opacity(0.35))
                        .multilineTextAlignment(.center).padding(.horizontal, 30)

                    Button(action: onDismiss) {
                        Text("Done")
                            .font(.system(size: 17, weight: .semibold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).frame(height: 56)
                            .background(scoreColor).cornerRadius(16)
                    }
                    .padding(.horizontal, 20).padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    DayScoreView(
        taskScores: ["sleep": 0.85, "physique": 0.70, "water": 0.0],
        totalTasks: ["sleep": "Track 8hrs sleep", "physique": "30min workout", "water": "Drink 8 glasses"],
        onDismiss: {}
    )
}
