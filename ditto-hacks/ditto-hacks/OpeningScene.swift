//
//  OpeningScene.swift
//  ditto-hacks
//
//  Created by Sudhit Muppa on 4/25/26.
//


//
//  OpeningScene.swift
//  ditto-hackathon
//

import SwiftUI

struct OpeningScene: View {
    @Binding var hasCompletedOpening: Bool
    @State private var step = 0
    @State private var introOpacity = 0.0
    @State private var selectedGoals: Set<String> = []
    @State private var currentRatings: [String: Double] = [:]
    @State private var cloningProgress = 0.0

    let goals: [(String, String)] = [
        ("Sleep", "moon.fill"),
        ("Fitness", "figure.run"),
        ("Nutrition", "leaf.fill"),
        ("Mental Health", "heart.fill"),
        ("Hydration", "drop.fill"),
        ("Productivity", "chart.bar.fill"),
        ("Social", "person.2.fill")
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch step {
            case 0: introView
            case 1: goalSelectionView
            case 2: currentRatingView
            case 3: cloningView
            default: EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: step)
    }

    // MARK: - Step 0: Intro
    var introView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 14) {
                Text("You have decided")
                    .font(.system(size: 26, weight: .light))
                    .foregroundColor(.white.opacity(0.55))

                Text("to become")
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(.white.opacity(0.7))

                Text("your ideal self.")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
            }
            .opacity(introOpacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.4)) {
                    introOpacity = 1.0
                }
            }

            Spacer()

            Button(action: { step = 1 }) {
                Text("Let's begin")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.45),
                                        lineWidth: 1
                                    )
                            )
                    )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
            .opacity(introOpacity)
        }
    }

    // MARK: - Step 1: Goal Selection
    var goalSelectionView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 6) {
                Text("What do you want to improve?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("Select everything that applies")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.38))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(goals, id: \.0) { goal in
                    GoalCard(
                        title: goal.0,
                        icon: goal.1,
                        isSelected: selectedGoals.contains(goal.0),
                        action: {
                            withAnimation(.spring(response: 0.25)) {
                                if selectedGoals.contains(goal.0) {
                                    selectedGoals.remove(goal.0)
                                } else {
                                    selectedGoals.insert(goal.0)
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: {
                for goal in selectedGoals where currentRatings[goal] == nil {
                    currentRatings[goal] = 3.0
                }
                step = 2
            }) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(selectedGoals.isEmpty ? .white.opacity(0.3) : .black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                selectedGoals.isEmpty
                                ? Color.white.opacity(0.06)
                                : Color(red: 0.0, green: 0.9, blue: 0.4)
                            )
                    )
            }
            .disabled(selectedGoals.isEmpty)
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
    }

    // MARK: - Step 2: Rate Current State
    var currentRatingView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text("Where are you now?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text("Rate your current state honestly")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.38))
            }
            .padding(.top, 70)
            .padding(.horizontal, 32)
            .padding(.bottom, 28)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Array(selectedGoals).sorted(), id: \.self) { goal in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(goal)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(ratingLabel(currentRatings[goal] ?? 3.0))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                            }
                            Slider(
                                value: Binding(
                                    get: { currentRatings[goal] ?? 3.0 },
                                    set: { currentRatings[goal] = $0 }
                                ),
                                in: 1...5,
                                step: 1
                            )
                            .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }

            Button(action: {
                step = 3
                startCloningAnimation()
            }) {
                Text("Create My Ditto")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(red: 0.0, green: 0.9, blue: 0.4))
                    )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
            .padding(.top, 16)
        }
    }

    // MARK: - Step 3: Cloning Animation
    var cloningView: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 3)
                    .frame(width: 110, height: 110)
                Circle()
                    .trim(from: 0, to: cloningProgress)
                    .stroke(
                        Color(red: 0.0, green: 0.9, blue: 0.4),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 2.2), value: cloningProgress)

                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
            }

            VStack(spacing: 10) {
                Text("Creating your ideal self...")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)

                Text("Your Ditto is taking shape")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.38))
            }

            Spacer()
        }
    }

    // MARK: - Helpers
    func ratingLabel(_ value: Double) -> String {
        switch Int(value) {
        case 1: return "Very poor"
        case 2: return "Below average"
        case 3: return "Average"
        case 4: return "Good"
        case 5: return "Excellent"
        default: return "Average"
        }
    }

    func startCloningAnimation() {
        withAnimation(.easeInOut(duration: 2.2)) {
            cloningProgress = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation {
                hasCompletedOpening = true
            }
        }
    }
}

// MARK: - GoalCard
struct GoalCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSelected ? .black : Color(red: 0.0, green: 0.9, blue: 0.4))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? .black : .white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected
                        ? Color(red: 0.0, green: 0.9, blue: 0.4)
                        : Color.white.opacity(0.05)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.clear : Color.white.opacity(0.09),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}