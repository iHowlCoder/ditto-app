//
//  DittoOnboardingFlow.swift
//  ditto-hacks
//
//  Onboarding flow per backend spec
//

import SwiftUI

struct DittoOnboardingFlow: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep = 0
    @State private var selectedCategories: Set<String> = []
    @State private var currentDescription = ""
    @State private var goalDescription = ""
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var availableCategories: [String] = []
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if currentStep == 0 {
                // Step 1: Cinematic intro
                CinematicIntroView {
                    withAnimation {
                        currentStep = 1
                    }
                }
            } else if currentStep == 1 {
                // Step 2: Category picker
                CategoryPickerView(
                    categories: availableCategories,
                    selectedCategories: $selectedCategories
                ) {
                    withAnimation {
                        currentStep = 2
                    }
                }
            } else if currentStep == 2 {
                // Step 3: Current state description
                DescriptionView(
                    title: "Where are you now?",
                    subtitle: "Describe your current state honestly",
                    text: $currentDescription,
                    placeholder: "I'm currently struggling with consistency, sleep schedule is irregular, haven't been exercising regularly..."
                ) {
                    withAnimation {
                        currentStep = 3
                    }
                }
            } else if currentStep == 3 {
                // Step 4: Goal description
                DescriptionView(
                    title: "Where do you want to be?",
                    subtitle: "Describe your ideal self",
                    text: $goalDescription,
                    placeholder: "I want to wake up early consistently, exercise 5x per week, have more energy..."
                ) {
                    withAnimation {
                        currentStep = 4
                    }
                }
            } else if currentStep == 4 {
                // Step 5: Loading/Processing
                OnboardingLoadingView(isProcessing: $isProcessing)
            } else if currentStep == 5 {
                // Step 6: Clone reveal
                CloneRevealView()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .task {
            await loadCategories()
        }
        .onChange(of: currentStep) { oldValue, newValue in
            if newValue == 4 {
                Task {
                    await submitOnboarding()
                }
            }
        }
    }
    
    private func loadCategories() async {
        do {
            let response = try await APIClient.shared.getCategories()
            availableCategories = response.categories
        } catch {
            errorMessage = "Failed to load categories"
            showError = true
        }
    }
    
    private func submitOnboarding() async {
        isProcessing = true
        
        do {
            try await appState.completeOnboarding(
                categories: Array(selectedCategories),
                currentDescription: currentDescription,
                goalDescription: goalDescription
            )
            
            // Wait a moment for dramatic effect
            try await Task.sleep(for: .seconds(2))
            
            withAnimation {
                currentStep = 5
            }
            
            isProcessing = false
            
            // After 3 seconds, close onboarding
            try await Task.sleep(for: .seconds(3))
            // AppState will handle routing to main app
            
        } catch {
            isProcessing = false
            errorMessage = "Failed to complete onboarding: \(error.localizedDescription)"
            showError = true
            currentStep = 1 // Go back to category picker
        }
    }
}

// MARK: - Step 1: Cinematic Intro
struct CinematicIntroView: View {
    let onContinue: () -> Void
    @State private var textOpacity = 0.0
    @State private var glowIntensity = 0.0
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("You've decided to find out")
                .font(.system(size: 28, weight: .light, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .opacity(textOpacity)

            Text("if a clone of you")
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.0, green: 0.9, blue: 0.4),
                            Color(red: 0.4, green: 1.0, blue: 0.6)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
                .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4).opacity(glowIntensity), radius: 20)
                .opacity(textOpacity)
                .padding(.top, 4)

            Text("can grow faster than you can.")
                .font(.system(size: 28, weight: .light, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .opacity(textOpacity)
                .padding(.top, 4)

            Text("Not to beat you — but to inspire you.")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .opacity(textOpacity)
                .padding(.top, 12)
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Begin")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0.0, green: 0.9, blue: 0.4))
                    )
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
            .opacity(textOpacity)
        }
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(.easeIn(duration: 1.5)) {
                textOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowIntensity = 0.6
            }
        }
    }
}

// MARK: - Step 2: Category Picker
struct CategoryPickerView: View {
    let categories: [String]
    @Binding var selectedCategories: Set<String>
    let onContinue: () -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Choose Your Focus")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Select the categories you want to improve")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.top, 60)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategories.contains(category)
                        ) {
                            if selectedCategories.contains(category) {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            VStack(spacing: 12) {
                Text("\(selectedCategories.count) categories selected")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(selectedCategories.isEmpty ? .white.opacity(0.3) : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedCategories.isEmpty ? Color.white.opacity(0.1) : Color(red: 0.0, green: 0.9, blue: 0.4))
                        )
                }
                .disabled(selectedCategories.isEmpty)
                .padding(.horizontal, 40)
            }
            .padding(.bottom, 40)
        }
    }
}

struct CategoryCard: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void
    
    var icon: String {
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
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(isSelected ? Color(red: 0.0, green: 0.9, blue: 0.4) : .white.opacity(0.6))
                
                Text(category.capitalized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color(red: 0.0, green: 0.9, blue: 0.4) : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Steps 3 & 4: Description Views
struct DescriptionView: View {
    let title: String
    let subtitle: String
    @Binding var text: String
    let placeholder: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60)
            .padding(.horizontal, 20)
            
            TextEditor(text: $text)
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding()
                .frame(height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 30)
            
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .offset(y: -120)
            }
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(text.isEmpty ? .white.opacity(0.3) : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(text.isEmpty ? Color.white.opacity(0.1) : Color(red: 0.0, green: 0.9, blue: 0.4))
                    )
            }
            .disabled(text.isEmpty)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Step 5: Loading View
struct OnboardingLoadingView: View {
    @Binding var isProcessing: Bool
    @State private var rotationAngle = 0.0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 4)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.9, blue: 0.4),
                                Color(red: 0.4, green: 1.0, blue: 0.6)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(rotationAngle))
            }
            
            VStack(spacing: 12) {
                Text("Creating Your Clones")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Analyzing your goals and generating\nyour personalized journey")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

// MARK: - Step 6: Clone Reveal
struct CloneRevealView: View {
    @EnvironmentObject var appState: AppState
    @State private var revealed = false
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Meet Your Clones")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 60)
            
            if let profile = appState.profile {
                HStack(spacing: 20) {
                    ClonePlaceholderCard(
                        label: "YOU",
                        color: .blue,
                        score: profile.you.average()
                    )
                    
                    ClonePlaceholderCard(
                        label: "AI CLONE",
                        color: .red,
                        score: profile.ai_nemesis.average()
                    )
                    
                    ClonePlaceholderCard(
                        label: "IDEAL SELF",
                        color: .yellow,
                        score: profile.ideal_self.average()
                    )
                }
                .padding(.horizontal, 20)
                .scaleEffect(revealed ? 1.0 : 0.8)
                .opacity(revealed ? 1.0 : 0.0)
                
                Text(profile.gap_vs_ideal.focus_message)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .opacity(revealed ? 1.0 : 0.0)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
                revealed = true
            }
        }
    }
}

struct ClonePlaceholderCard: View {
    let label: String
    let color: Color
    let score: Float
    
    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.2))
                .frame(height: 140)
                .overlay(
                    VStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(color)
                        Text("3D Model\nComing Soon")
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(color.opacity(0.7))
                    }
                )
            
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
            
            Text(String(format: "%.0f%%", score * 100))
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

#Preview {
    DittoOnboardingFlow()
        .environmentObject(AppState.shared)
}
