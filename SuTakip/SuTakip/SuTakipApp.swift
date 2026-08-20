import SwiftUI
import UserNotifications

@main
struct SuTakipApp: App {
    @StateObject private var appState = AppState.shared

    init() {
        NotificationService.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
                .task {
                    await NotificationService.shared.refreshAll(from: appState)
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.isVIP {
                VIPHomeView()
            } else {
                StandardTabView()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.35), value: appState.isVIP)
    }
}
