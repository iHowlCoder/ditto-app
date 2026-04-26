//
//  ProfileView.swift
//  ditto-hacks
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLogoutConfirmation = false
    @State private var showDayScore = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let profile = appState.profile {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {

                        // Avatar / name / email
                        VStack(spacing: 16) {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(red: 0.0, green: 0.9, blue: 0.4),
                                             Color(red: 0.4, green: 1.0, blue: 0.6)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(String(profile.user.username.prefix(1)).uppercased())
                                        .font(.system(size: 42, weight: .bold))
                                        .foregroundColor(.black)
                                )
                            Text(profile.user.username)
                                .font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                            Text(profile.user.email)
                                .font(.system(size: 15)).foregroundColor(.white.opacity(0.6))
                            Text("Member since \(formatDate(profile.user.member_since))")
                                .font(.system(size: 13, weight: .medium)).foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.top, 40)

                        // Stats
                        VStack(spacing: 12) {
                            HStack {
                                Text("Statistics").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                                Spacer()
                            }.padding(.horizontal, 20)

                            HStack(spacing: 12) {
                                StatCard(title: "Current Streak", value: "\(profile.streak.days)",
                                         unit: "days", color: Color(red: 0.0, green: 0.9, blue: 0.4))
                                StatCard(title: "Today", value: "\(profile.streak.habits_today)",
                                         unit: "habits", color: .blue)
                            }.padding(.horizontal, 20)
                        }

                        // Actions
                        VStack(spacing: 12) {
                            HStack {
                                Text("Actions").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                                Spacer()
                            }.padding(.horizontal, 20)

                            VStack(spacing: 8) {
                                // Refresh
                                Button(action: { Task { try? await appState.refreshProfile() } }) {
                                    actionRow(icon: "arrow.clockwise", label: "Refresh Data",
                                              color: .white, bg: Color.white.opacity(0.05),
                                              border: Color.white.opacity(0.1))
                                }

                                // End Day
                                Button(action: { showDayScore = true }) {
                                    actionRow(icon: "moon.stars.fill", label: "End Day & See Score",
                                              color: Color(red: 0.0, green: 0.9, blue: 0.4),
                                              bg: Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.1),
                                              border: Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.3))
                                }

                                // Logout
                                Button(action: { showLogoutConfirmation = true }) {
                                    actionRow(icon: "rectangle.portrait.and.arrow.right", label: "Logout",
                                              color: .red, bg: Color.red.opacity(0.1),
                                              border: Color.red.opacity(0.2))
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 40)
                    }
                }
            } else {
                ProgressView().tint(.white)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Are you sure you want to logout?",
                            isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
            Button("Logout", role: .destructive) { appState.logout() }
            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showDayScore) {
            if let profile = appState.profile {
                DayScoreView(
                    taskScores: appState.dailyTaskScores,
                    totalTasks: profile.todays_tasks,
                    onDismiss: {
                        showDayScore = false
                        appState.dailyTaskScores = [:]
                    }
                )
            }
        }
    }

    @ViewBuilder
    private func actionRow(icon: String, label: String, color: Color, bg: Color, border: Color) -> some View {
        HStack {
            Image(systemName: icon).font(.system(size: 16))
            Text(label).font(.system(size: 16, weight: .semibold))
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(color.opacity(0.5))
        }
        .foregroundColor(color)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(bg)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(border, lineWidth: 1)))
    }

    private func formatDate(_ dateString: String) -> String {
        let c = dateString.split(separator: "-")
        return c.count >= 2 ? "\(c[1])/\(c[0])" : dateString
    }
}

struct StatCard: View {
    let title: String; let value: String; let unit: String; let color: Color
    var body: some View {
        VStack(spacing: 8) {
            Text(title).font(.system(size: 13, weight: .medium)).foregroundColor(.white.opacity(0.6))
            Text(value).font(.system(size: 32, weight: .bold)).foregroundColor(color)
            Text(unit).font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 20)
        .background(RoundedRectangle(cornerRadius: 16).fill(color.opacity(0.1))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.3), lineWidth: 1)))
    }
}

#Preview {
    NavigationStack { ProfileView().environmentObject(AppState.shared) }
}
