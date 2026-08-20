import SwiftUI

struct VIPHomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showSettings = false
    @State private var featuredMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Merhaba, \(appState.nickname)")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(AppTheme.ink)
                            Text("Bugün de yanındayım")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.muted)
                        }
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.title)
                            .foregroundStyle(AppTheme.pastelPurple)
                    }

                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(AppTheme.pastelOrange)
                        Text(featuredMessage.isEmpty ? appState.randomRomanticMessage : featuredMessage)
                            .font(.title3.weight(.medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppTheme.ink)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(22)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(AppTheme.pastelPurple.opacity(0.28))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(AppTheme.pastelPurple.opacity(0.5), lineWidth: 1)
                    )

                    VStack(spacing: 16) {
                        Text("Su paneli")
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ZStack {
                            WaterProgressRing(progress: appState.progress, size: 168)
                            VStack(spacing: 4) {
                                Image(systemName: "drop.fill")
                                    .foregroundStyle(AppTheme.pastelGreen)
                                Text("\(appState.todayIntakeML) ml")
                                    .font(.title2.bold())
                                    .foregroundStyle(AppTheme.ink)
                                Text("hedef \(appState.dailyGoalML)")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.muted)
                            }
                        }

                        HStack(spacing: 10) {
                            PastelChipButton(title: "Bardak", systemImage: "cup.and.saucer.fill", tone: .green) {
                                appState.addWater(200)
                            }
                            PastelChipButton(title: "Şişe", systemImage: "waterbottle.fill", tone: .orange) {
                                appState.addWater(500)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(AppTheme.hairline, lineWidth: 1)
                    )
                }
                .padding(24)
            }
            .background(AppTheme.background)
            .navigationTitle("Senin için")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(AppTheme.pastelPurpleDeep)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                VIPSettingsView()
                    .environmentObject(appState)
            }
            .onAppear {
                featuredMessage = appState.randomRomanticMessage
            }
        }
    }
}

struct VIPSettingsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var messagesText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    labeled("İsim") {
                        TextField("Takma ad", text: $appState.nickname)
                            .padding(12)
                            .background(AppTheme.hairline.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                    }

                    labeled("Günlük su hedefi") {
                        Stepper(value: $appState.dailyGoalML, in: 500...5000, step: 100) {
                            Text("\(appState.dailyGoalML) ml")
                        }
                    }

                    labeled("Su bildirimi aralığı") {
                        Toggle("Hatırlatmalar", isOn: $appState.notificationsEnabled)
                            .tint(AppTheme.pastelGreen)
                        Stepper(value: $appState.reminderMinutes, in: 15...240, step: 15) {
                            Text("\(appState.reminderMinutes) dakika")
                        }
                    }

                    labeled("Romantik sürprizler") {
                        Toggle("Rastgele mesaj bildirimleri", isOn: $appState.romanticAlertsEnabled)
                            .tint(AppTheme.pastelPurple)
                        Text("Her satır ayrı bir mesaj olur.")
                            .font(.caption)
                            .foregroundStyle(AppTheme.muted)
                        TextEditor(text: $messagesText)
                            .frame(minHeight: 160)
                            .padding(8)
                            .scrollContentBackground(.hidden)
                            .background(AppTheme.hairline.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(24)
            }
            .background(AppTheme.background)
            .navigationTitle("VIP Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        let lines = messagesText
                            .split(separator: "\n")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                        if !lines.isEmpty {
                            appState.romanticMessages = lines
                        }
                        Task { await NotificationService.shared.refreshAll(from: appState) }
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.pastelPurpleDeep)
                }
            }
            .onAppear {
                messagesText = appState.romanticMessages.joined(separator: "\n")
            }
        }
        .presentationDetents([.large])
    }

    private func labeled<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.ink)
            content()
        }
    }
}
