import WidgetKit
import SwiftUI

struct WaterEntry: TimelineEntry {
    let date: Date
    let intake: Int
    let goal: Int
    let isVIP: Bool
    let nickname: String
    let message: String

    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(1, Double(intake) / Double(goal))
    }
}

struct WaterProvider: TimelineProvider {
    func placeholder(in context: Context) -> WaterEntry {
        snapshotEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (WaterEntry) -> Void) {
        completion(snapshotEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterEntry>) -> Void) {
        let entry = snapshotEntry()
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func snapshotEntry() -> WaterEntry {
        SharedStore.rolloverIfNeeded()
        let d = SharedStore.defaults
        let messages = d.stringArray(forKey: SharedKeys.romanticMessages) ?? []
        let isVIP = d.bool(forKey: SharedKeys.isVIP)
        return WaterEntry(
            date: Date(),
            intake: d.integer(forKey: SharedKeys.todayIntakeML),
            goal: max(1, d.integer(forKey: SharedKeys.dailyGoalML)),
            isVIP: isVIP,
            nickname: d.string(forKey: SharedKeys.nickname) ?? "Aşkım",
            message: isVIP ? (messages.randomElement() ?? "Su iç, seni bekliyorum.") : "Bugünkü su"
        )
    }
}

struct SuTakipWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SuTakipLockScreen", provider: WaterProvider()) { entry in
            WaterWidgetView(entry: entry)
                .containerBackground(for: .widget) { Color.clear }
        }
        .configurationDisplayName("Su Takip")
        .description("Kilit ekranı su özeti.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

struct WaterWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WaterEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            circular
        case .accessoryRectangular:
            rectangular
        default:
            circular
        }
    }

    private var circular: some View {
        Gauge(value: entry.progress) {
            Image(systemName: "drop.fill")
        } currentValueLabel: {
            Text("\(Int(entry.progress * 100))")
                .font(.system(.caption, design: .rounded).bold())
        }
        .gaugeStyle(.accessoryCircular)
        .widgetAccentable()
        .accessibilityLabel("Su ilerlemesi yüzde \(Int(entry.progress * 100))")
    }

    private var rectangular: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: entry.isVIP ? "heart.fill" : "drop.fill")
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.isVIP ? "\(entry.nickname) · su" : "Su takip")
                    .font(.headline)
                    .lineLimit(1)
                Text("\(entry.intake)/\(entry.goal) ml")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if entry.isVIP {
                    Text(entry.message)
                        .font(.caption2)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .widgetAccentable()
        .accessibilityLabel("\(entry.intake) mililitre, hedef \(entry.goal)")
    }
}

#Preview(as: .accessoryCircular) {
    SuTakipWidget()
} timeline: {
    WaterEntry(date: .now, intake: 900, goal: 2000, isVIP: true, nickname: "Aşkım", message: "Bir yudum daha")
}

#Preview(as: .accessoryRectangular) {
    SuTakipWidget()
} timeline: {
    WaterEntry(date: .now, intake: 900, goal: 2000, isVIP: true, nickname: "Aşkım", message: "Seni düşünüyorum")
}
