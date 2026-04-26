//
//  LoginView.swift
//  ditto-hackathon
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showEmailError = false
    @Binding var isLoggedIn: Bool

    var isValidEmail: Bool {
        let pattern = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // MARK: - Logo / Title
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.12))
                            .frame(width: 72, height: 72)
                        Text("D")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                    }
                    .padding(.bottom, 8)

                    Text("Welcome back")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.45))

                    Text("Ditto")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 52)

                // MARK: - Fields
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Email")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.45))
                            .padding(.leading, 2)

                        TextField(
                            "",
                            text: $email,
                            prompt: Text("you@example.com").foregroundColor(.white.opacity(0.22))
                        )
                        .foregroundColor(.white)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            showEmailError
                                            ? Color.red.opacity(0.6)
                                            : Color.white.opacity(0.1),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .onChange(of: email) { _, _ in
                            if showEmailError { showEmailError = false }
                        }

                        if showEmailError {
                            Text("Please enter a valid email address")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.red.opacity(0.8))
                                .padding(.leading, 2)
                                .transition(.opacity)
                        }
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        Text("Password")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.45))
                            .padding(.leading, 2)

                        SecureField(
                            "",
                            text: $password,
                            prompt: Text("Enter your password").foregroundColor(.white.opacity(0.22))
                        )
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 32)

                // MARK: - Continue Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if isValidEmail {
                            isLoggedIn = true
                        } else {
                            showEmailError = true
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(red: 0.0, green: 0.9, blue: 0.4))
                    )
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)

                Spacer()
                Spacer()
            }
        }
    }
}
