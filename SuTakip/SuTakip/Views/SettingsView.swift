import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var activationCode = ""
    @State private var codeHint: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    settingsCard("Hedef") {
                        Stepper(value: $appState.dailyGoalML, in: 500...5000, step: 100) {
                            Text("Günlük hedef: \(appState.dailyGoalML) ml")
                                .foregroundStyle(AppTheme.ink)
                        }
                    }

                    settingsCard("Bildirimler") {
                        Toggle("Su hatırlatmaları", isOn: $appState.notificationsEnabled)
                            .tint(AppTheme.pastelGreen)
                            .onChange(of: appState.notificationsEnabled) { _, _ in
                                Task { await NotificationService.shared.refreshAll(from: appState) }
                            }

                        Stepper(value: $appState.reminderMinutes, in: 15...240, step: 15) {
                            Text("Aralık: \(appState.reminderMinutes) dk")
                                .foregroundStyle(AppTheme.ink)
                        }
                        .onChange(of: appState.reminderMinutes) { _, _ in
                            Task { await NotificationService.shared.scheduleWaterReminder(from: appState) }
                        }
                    }

                    Color.clear.frame(height: 180)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Aktivasyon Kodu")
                            .font(.caption)
                            .foregroundStyle(AppTheme.muted.opacity(0.7))
                        SecureField("", text: $activationCode)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                            .padding(12)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppTheme.hairline, lineWidth: 1)
                            )
                            .onSubmit(tryActivate)
                            .onChange(of: activationCode) { _, newValue in
                                if newValue.count >= 4 {
                                    tryActivate()
                                }
                            }
                        if let codeHint {
                            Text(codeHint)
                                .font(.caption2)
                                .foregroundStyle(AppTheme.pastelOrangeDeep)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 80)
                }
                .padding(24)
            }
            .background(AppTheme.background)
            .navigationTitle("Ayarlar")
        }
    }

    private func settingsCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.ink)
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.hairline.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func tryActivate() {
        if appState.activateVIP(code: activationCode) {
            codeHint = nil
        } else if !activationCode.isEmpty {
            codeHint = "Kod geçersiz."
        }
    }
}
