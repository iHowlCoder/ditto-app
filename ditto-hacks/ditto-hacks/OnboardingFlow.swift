//
//  OnboardingFlow.swift
//  ditto-hackathon
//
//  Created by Yashdeep on 4/25/26.
//

import SwiftUI

struct OnboardingFlow: View {
    @State private var currentStep = 0
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var selectedGender = ""
    @State private var age = ""
    @State private var weight = ""
    @State private var height = ""
    @State private var useKg = false // false = lbs, true = kg
    @State private var useCm = false // false = ft/in, true = cm
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                if currentStep == 0 {
                    NameView(firstName: $firstName, lastName: $lastName, onContinue: {
                        withAnimation {
                            currentStep = 1
                        }
                    })
                } else if currentStep == 1 {
                    GenderView(selectedGender: $selectedGender, onContinue: {
                        withAnimation {
                            currentStep = 2
                        }
                    })
                } else if currentStep == 2 {
                    AgeView(age: $age, onContinue: {
                        withAnimation {
                            currentStep = 3
                        }
                    })
                } else if currentStep == 3 {
                    WeightView(weight: $weight, useKg: $useKg, onContinue: {
                        withAnimation {
                            currentStep = 4
                        }
                    })
                } else if currentStep == 4 {
                    HeightView(height: $height, useCm: $useCm, onContinue: {
                        // Complete onboarding
                        hasCompletedOnboarding = true
                    })
                }
            }
        }
    }
}

// MARK: - Name View
struct NameView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("What is your name?")
                .font(.system(size: 28, weight: .semibold, design: .default))
                .foregroundColor(Color.white)
            
            HStack(spacing: 12) {
                TextField("First", text: $firstName)
                    .foregroundColor(Color.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .autocorrectionDisabled()
                
                TextField("Last", text: $lastName)
                    .foregroundColor(Color.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 40)
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.0, green: 0.9, blue: 0.4))
                    )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Gender View
struct GenderView: View {
    @Binding var selectedGender: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("What is your gender?")
                .font(.system(size: 28, weight: .semibold, design: .default))
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                Button(action: {
                    selectedGender = "Male"
                }) {
                    Text("Male")
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(selectedGender == "Male" ? .white : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedGender == "Male" ? Color(red: 0.0, green: 0.9, blue: 0.4) : Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedGender == "Male" ? Color.clear : Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                
                Button(action: {
                    selectedGender = "Female"
                }) {
                    Text("Female")
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(selectedGender == "Female" ? .white : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedGender == "Female" ? Color(red: 0.0, green: 0.9, blue: 0.4) : Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedGender == "Female" ? Color.clear : Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 40)
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.0, green: 0.9, blue: 0.4))
                    )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Age View
struct AgeView: View {
    @Binding var age: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("What is your age?")
                .font(.system(size: 28, weight: .semibold, design: .default))
                .foregroundColor(.white)
            
            TextField("Age", text: $age)
                .foregroundColor(Color.white)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 40)
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.0, green: 0.9, blue: 0.4))
                    )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Weight View
struct WeightView: View {
    @Binding var weight: String
    @Binding var useKg: Bool
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("What is your weight?")
                .font(.system(size: 28, weight: .semibold, design: .default))
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                TextField("Weight", text: $weight)
                    .foregroundColor(Color.white)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                
                // Unit toggle
                HStack(spacing: 12) {
                    Text("lbs")
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Toggle("", isOn: $useKg)
                        .labelsHidden()
                        .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                    
                    Text("kg")
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 40)
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.0, green: 0.9, blue: 0.4))
                    )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Height View
struct HeightView: View {
    @Binding var height: String
    @Binding var useCm: Bool
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("What is your height?")
                .font(.system(size: 28, weight: .semibold, design: .default))
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                TextField("Height", text: $height)
                    .foregroundColor(Color.white)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                
                // Unit toggle
                HStack(spacing: 12) {
                    Text("ft/in")
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Toggle("", isOn: $useCm)
                        .labelsHidden()
                        .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                    
                    Text("cm")
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 40)
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.0, green: 0.9, blue: 0.4))
                    )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}
