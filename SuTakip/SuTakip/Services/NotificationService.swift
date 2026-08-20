import Foundation
import UserNotifications

@MainActor
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    private override init() {
        super.init()
    }

    func configure() {
        UNUserNotificationCenter.current().delegate = self
        registerCategories()
    }

    func registerCategories() {
        let confirm = UNNotificationAction(
            identifier: NotificationIDs.confirmAction,
            title: "Onayla",
            options: []
        )
        let snooze = UNNotificationAction(
            identifier: NotificationIDs.snoozeAction,
            title: "Onaylama",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: NotificationIDs.waterCategory,
            actions: [confirm, snooze],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func requestPermission() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }

    func refreshAll(from state: AppState) async {
        await requestPermission()
        if state.notificationsEnabled {
            await scheduleWaterReminder(from: state)
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: [NotificationIDs.waterRequest, NotificationIDs.snoozeRequest]
            )
        }

        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: (0..<8).map { "\(NotificationIDs.romanticPrefix)\($0)" }
        )
        if state.isVIP && state.romanticAlertsEnabled {
            scheduleRomanticSurprises(from: state)
        }
    }

    func scheduleWaterReminder(from state: AppState) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [NotificationIDs.waterRequest]
        )
        guard state.notificationsEnabled else { return }

        let interval = TimeInterval(max(15, state.reminderMinutes) * 60)
        let content = waterContent(from: state, body: waterBody(from: state))
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(
            identifier: NotificationIDs.waterRequest,
            content: content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    func scheduleSnoozeReminder(from state: AppState) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [NotificationIDs.snoozeRequest]
        )
        let content = waterContent(
            from: state,
            body: "Hâlâ su içmedin. 90 saniye geçti, şimdi iç lütfen."
        )
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 90, repeats: false)
        let request = UNNotificationRequest(
            identifier: NotificationIDs.snoozeRequest,
            content: content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    func scheduleRomanticSurprises(from state: AppState) {
        var elapsed: TimeInterval = 20 * 60
        for index in 0..<6 {
            elapsed += TimeInterval(Int.random(in: 45 * 60 ... 3 * 60 * 60))
            let content = UNMutableNotificationContent()
            content.title = state.nickname.isEmpty ? "Sürpriz" : state.nickname
            content.body = state.randomRomanticMessage
            content.sound = .default
            content.interruptionLevel = .active
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: elapsed, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(NotificationIDs.romanticPrefix)\(index)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }
    }

    private func waterContent(from state: AppState, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = state.isVIP ? "Su zamanı, \(state.nickname)" : "Su hatırlatması"
        content.body = body
        content.sound = .default
        content.categoryIdentifier = NotificationIDs.waterCategory
        content.interruptionLevel = .timeSensitive
        return content
    }

    private func waterBody(from state: AppState) -> String {
        if state.isVIP {
            return "Bir bardak su iç, sonra onayla. \(state.remainingML) ml kaldı."
        }
        return "Su içme zamanı. Hedefe \(state.remainingML) ml kaldı."
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await handle(response)
    }

    private func handle(_ response: UNNotificationResponse) async {
        let state = AppState.shared
        switch response.actionIdentifier {
        case NotificationIDs.confirmAction:
            state.resetDrinkingInterval()
            await scheduleWaterReminder(from: state)
        case NotificationIDs.snoozeAction:
            await scheduleSnoozeReminder(from: state)
        default:
            break
        }
    }
}
