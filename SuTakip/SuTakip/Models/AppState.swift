import Foundation
import Combine
import WidgetKit

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    private let d = SharedStore.defaults

    @Published var isVIP: Bool {
        didSet {
            d.set(isVIP, forKey: SharedKeys.isVIP)
            UserDefaults.standard.set(isVIP, forKey: SharedKeys.isVIP)
        }
    }

    @Published var dailyGoalML: Int {
        didSet {
            d.set(dailyGoalML, forKey: SharedKeys.dailyGoalML)
            reloadWidgets()
        }
    }

    @Published var todayIntakeML: Int {
        didSet {
            d.set(todayIntakeML, forKey: SharedKeys.todayIntakeML)
            reloadWidgets()
        }
    }

    @Published var lastDrinkDate: Date? {
        didSet { d.set(lastDrinkDate, forKey: SharedKeys.lastDrinkDate) }
    }

    @Published var reminderMinutes: Int {
        didSet { d.set(reminderMinutes, forKey: SharedKeys.reminderMinutes) }
    }

    @Published var nickname: String {
        didSet { d.set(nickname, forKey: SharedKeys.nickname) }
    }

    @Published var romanticMessages: [String] {
        didSet { d.set(romanticMessages, forKey: SharedKeys.romanticMessages) }
    }

    @Published var notificationsEnabled: Bool {
        didSet { d.set(notificationsEnabled, forKey: SharedKeys.notificationsEnabled) }
    }

    @Published var romanticAlertsEnabled: Bool {
        didSet { d.set(romanticAlertsEnabled, forKey: SharedKeys.romanticAlertsEnabled) }
    }

    init() {
        let d = SharedStore.defaults
        if d.object(forKey: SharedKeys.dailyGoalML) == nil {
            d.set(2000, forKey: SharedKeys.dailyGoalML)
        }
        if d.object(forKey: SharedKeys.reminderMinutes) == nil {
            d.set(90, forKey: SharedKeys.reminderMinutes)
        }
        if d.object(forKey: SharedKeys.notificationsEnabled) == nil {
            d.set(true, forKey: SharedKeys.notificationsEnabled)
        }
        if d.object(forKey: SharedKeys.romanticAlertsEnabled) == nil {
            d.set(true, forKey: SharedKeys.romanticAlertsEnabled)
        }
        if d.string(forKey: SharedKeys.nickname) == nil {
            d.set("Aşkım", forKey: SharedKeys.nickname)
        }
        if d.array(forKey: SharedKeys.romanticMessages) == nil {
            d.set(Self.defaultMessages, forKey: SharedKeys.romanticMessages)
        }

        SharedStore.rolloverIfNeeded()

        isVIP = d.bool(forKey: SharedKeys.isVIP) || UserDefaults.standard.bool(forKey: SharedKeys.isVIP)
        dailyGoalML = d.integer(forKey: SharedKeys.dailyGoalML)
        todayIntakeML = d.integer(forKey: SharedKeys.todayIntakeML)
        lastDrinkDate = d.object(forKey: SharedKeys.lastDrinkDate) as? Date
        reminderMinutes = max(15, d.integer(forKey: SharedKeys.reminderMinutes))
        nickname = d.string(forKey: SharedKeys.nickname) ?? "Aşkım"
        romanticMessages = d.stringArray(forKey: SharedKeys.romanticMessages) ?? Self.defaultMessages
        notificationsEnabled = d.bool(forKey: SharedKeys.notificationsEnabled)
        romanticAlertsEnabled = d.bool(forKey: SharedKeys.romanticAlertsEnabled)
    }

    static let defaultMessages = [
        "Seni düşünüyorum. Bir yudum su iç, içim rahatlasın.",
        "Kalbin kadar taze kal. Su iç lütfen.",
        "Uzakta olsam da hatırlatırım: susuz kalma.",
        "Bugün de yanındayım. Küçük bir bardak yeter.",
        "Gülüşün gibi berrak ol. Su zamanı."
    ]

    static let activationCode = "1234"

    var progress: Double {
        guard dailyGoalML > 0 else { return 0 }
        return Double(todayIntakeML) / Double(dailyGoalML)
    }

    var remainingML: Int {
        max(0, dailyGoalML - todayIntakeML)
    }

    var randomRomanticMessage: String {
        romanticMessages.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.randomElement()
            ?? Self.defaultMessages[0]
    }

    func addWater(_ milliliters: Int) {
        SharedStore.rolloverIfNeeded()
        todayIntakeML = d.integer(forKey: SharedKeys.todayIntakeML) + milliliters
        resetDrinkingInterval()
    }

    func resetDrinkingInterval() {
        lastDrinkDate = Date()
        Task { await NotificationService.shared.scheduleWaterReminder(from: self) }
    }

    func activateVIP(code: String) -> Bool {
        guard code.trimmingCharacters(in: .whitespacesAndNewlines) == Self.activationCode else {
            return false
        }
        isVIP = true
        Task { await NotificationService.shared.refreshAll(from: self) }
        reloadWidgets()
        return true
    }

    func historyLast7Days() -> [(date: Date, amount: Int)] {
        SharedStore.rolloverIfNeeded()
        SharedStore.saveHistory(day: SharedStore.dayStamp(), amount: todayIntakeML)
        let history = SharedStore.loadHistory()
        let cal = Calendar.current
        return (0..<7).compactMap { offset -> (Date, Int)? in
            guard let day = cal.date(byAdding: .day, value: -offset, to: cal.startOfDay(for: Date())) else {
                return nil
            }
            let stamp = SharedStore.dayStamp(for: day)
            return (day, history[stamp] ?? (offset == 0 ? todayIntakeML : 0))
        }.reversed()
    }

    private func reloadWidgets() {
        WidgetKit.WidgetCenter.shared.reloadAllTimelines()
    }
}
