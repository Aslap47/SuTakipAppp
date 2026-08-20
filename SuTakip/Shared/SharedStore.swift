import Foundation

enum SharedStore {
    static var defaults: UserDefaults {
        UserDefaults(suiteName: SharedKeys.appGroupID) ?? .standard
    }

    static func dayStamp(for date: Date = Date()) -> String {
        let f = DateFormatter()
        f.calendar = Calendar.current
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    static func rolloverIfNeeded() {
        let d = defaults
        let today = dayStamp()
        let stored = d.string(forKey: SharedKeys.intakeDayStamp)
        if stored != today {
            if let stored {
                saveHistory(day: stored, amount: d.integer(forKey: SharedKeys.todayIntakeML))
            }
            d.set(0, forKey: SharedKeys.todayIntakeML)
            d.set(today, forKey: SharedKeys.intakeDayStamp)
        }
    }

    static func saveHistory(day: String, amount: Int) {
        var history = loadHistory()
        history[day] = amount
        let trimmed = history
            .sorted { $0.key > $1.key }
            .prefix(14)
        let dict = Dictionary(uniqueKeysWithValues: trimmed.map { ($0.key, $0.value) })
        if let data = try? JSONEncoder().encode(dict) {
            defaults.set(data, forKey: SharedKeys.historyJSON)
        }
    }

    static func loadHistory() -> [String: Int] {
        guard let data = defaults.data(forKey: SharedKeys.historyJSON),
              let dict = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return dict
    }
}
