//
//  AuthView.swift
//  ditto-hacks
//
//  Login and Registration screens
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var loginEmail = ""
    @State private var loginPassword = ""
    @State private var registerEmail = ""
    @State private var registerUsername = ""
    @State private var registerPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.0, blue: 0.15),
                    Color(red: 0.1, green: 0.0, blue: 0.25),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Logo/Title
                VStack(spacing: 12) {
                    Text("DITTO")
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
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
                        .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.5), radius: 20)
                    
                    Text("Become your ideal self")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 80)
                
                // Tab selector
                HStack(spacing: 0) {
                    Button(action: { selectedTab = 0 }) {
                        Text("Login")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(selectedTab == 0 ? .white : .white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                selectedTab == 0 ?
                                Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.2) :
                                Color.clear
                            )
                    }
                    
                    Button(action: { selectedTab = 1 }) {
                        Text("Sign Up")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(selectedTab == 1 ? .white : .white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                selectedTab == 1 ?
                                Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.2) :
                                Color.clear
                            )
                    }
                }
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 40)
                
                // Forms
                if selectedTab == 0 {
                    LoginForm(
                        email: $loginEmail,
                        password: $loginPassword,
                        onLogin: loginAction
                    )
                    .transition(.opacity)
                } else {
                    RegisterForm(
                        email: $registerEmail,
                        username: $registerUsername,
                        password: $registerPassword,
                        onRegister: registerAction
                    )
                    .transition(.opacity)
                }
                
                Spacer()
            }
            
            if appState.isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loginAction() {
        guard !loginEmail.isEmpty, !loginPassword.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        Task {
            do {
                try await appState.login(email: loginEmail, password: loginPassword)
            } catch {
                errorMessage = "Login failed: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    private func registerAction() {
        guard !registerEmail.isEmpty, !registerUsername.isEmpty, !registerPassword.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        Task {
            do {
                try await appState.register(email: registerEmail, username: registerUsername, password: registerPassword)
            } catch {
                errorMessage = "Registration failed: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

// MARK: - Login Form
struct LoginForm: View {
    @Binding var email: String
    @Binding var password: String
    let onLogin: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                
                SecureField("Password", text: $password)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            .padding(.horizontal, 40)
            
            Button(action: onLogin) {
                Text("Login")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.0, green: 0.9, blue: 0.4))
                    )
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
        }
    }
}

// MARK: - Register Form
struct RegisterForm: View {
    @Binding var email: String
    @Binding var username: String
    @Binding var password: String
    let onRegister: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                
                SecureField("Password", text: $password)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            .padding(.horizontal, 40)
            
            Button(action: onRegister) {
                Text("Create Account")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.0, green: 0.9, blue: 0.4))
                    )
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AppState.shared)
}
