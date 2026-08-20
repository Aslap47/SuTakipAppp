import Foundation

enum SharedKeys {
    static let appGroupID = "group.com.can.sutakip"
    static let isVIP = "isVIP"
    static let dailyGoalML = "dailyGoalML"
    static let todayIntakeML = "todayIntakeML"
    static let intakeDayStamp = "intakeDayStamp"
    static let lastDrinkDate = "lastDrinkDate"
    static let reminderMinutes = "reminderMinutes"
    static let nickname = "nickname"
    static let romanticMessages = "romanticMessages"
    static let notificationsEnabled = "notificationsEnabled"
    static let romanticAlertsEnabled = "romanticAlertsEnabled"
    static let historyJSON = "historyJSON"
}

enum NotificationIDs {
    static let waterCategory = "WATER_REMINDER"
    static let confirmAction = "CONFIRM_DRINK"
    static let snoozeAction = "DECLINE_DRINK"
    static let waterRequest = "water.reminder.next"
    static let snoozeRequest = "water.reminder.snooze"
    static let romanticPrefix = "romantic.surprise."
}
