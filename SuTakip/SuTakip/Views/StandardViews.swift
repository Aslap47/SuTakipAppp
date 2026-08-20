import SwiftUI

struct StandardTabView: View {
    var body: some View {
        TabView {
            StandardHomeView()
                .tabItem {
                    Image(systemName: "drop.fill")
                    Text("Su")
                }
            HistoryView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Geçmiş")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Ayarlar")
                }
        }
        .tint(AppTheme.pastelPurpleDeep)
        .background(AppTheme.background)
    }
}

struct StandardHomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    Text("Bugünkü su")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppTheme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ZStack {
                        WaterProgressRing(progress: appState.progress)
                        VStack(spacing: 6) {
                            Image(systemName: "drop.fill")
                                .font(.title)
                                .foregroundStyle(AppTheme.pastelPurple)
                            Text("\(appState.todayIntakeML)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)
                            Text("/ \(appState.dailyGoalML) ml")
                                .font(.footnote)
                                .foregroundStyle(AppTheme.muted)
                        }
                    }
                    .padding(.top, 8)

                    Text(remainingCopy)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)

                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            PastelChipButton(title: "+200 ml", systemImage: "drop", tone: .purple) {
                                appState.addWater(200)
                            }
                            PastelChipButton(title: "+250 ml", systemImage: "drop.fill", tone: .green) {
                                appState.addWater(250)
                            }
                        }
                        HStack(spacing: 10) {
                            PastelChipButton(title: "+330 ml", systemImage: "cup.and.saucer.fill", tone: .orange) {
                                appState.addWater(330)
                            }
                            PastelChipButton(title: "+500 ml", systemImage: "waterbottle.fill", tone: .purple) {
                                appState.addWater(500)
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background(AppTheme.background)
            .navigationTitle("Su Takip")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var remainingCopy: String {
        if appState.todayIntakeML >= appState.dailyGoalML {
            return "Günlük hedef tamam."
        }
        return "Hedefe \(appState.remainingML) ml kaldı."
    }
}

struct HistoryView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            let days = appState.historyLast7Days()
            let maxValue = max(days.map(\.amount).max() ?? 1, 1)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Son 7 gün")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)

                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(Array(days.enumerated()), id: \.offset) { _, item in
                            VStack(spacing: 8) {
                                Capsule()
                                    .fill(AppTheme.pastelGreen)
                                    .frame(height: max(8, CGFloat(item.amount) / CGFloat(maxValue) * 140))
                                Text(shortDay(item.date))
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.muted)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 180)
                    .padding(20)
                    .background(AppTheme.hairline.opacity(0.5), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                    ForEach(Array(days.reversed().enumerated()), id: \.offset) { _, item in
                        HStack {
                            Text(fullDay(item.date))
                                .foregroundStyle(AppTheme.ink)
                            Spacer()
                            Text("\(item.amount) ml")
                                .foregroundStyle(AppTheme.muted)
                        }
                        .padding(.vertical, 8)
                        Divider().background(AppTheme.hairline)
                    }
                }
                .padding(24)
            }
            .background(AppTheme.background)
            .navigationTitle("Geçmiş")
        }
    }

    private func shortDay(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "EE"
        return f.string(from: date)
    }

    private func fullDay(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateStyle = .medium
        return f.string(from: date)
    }
}
