import SwiftUI

enum AppTheme {
    static let background = Color.white
    static let ink = Color(red: 0.18, green: 0.18, blue: 0.22)
    static let muted = Color(red: 0.55, green: 0.55, blue: 0.60)
    static let hairline = Color(red: 0.93, green: 0.93, blue: 0.94)

    static let pastelPurple = Color(red: 0.78, green: 0.70, blue: 0.92)
    static let pastelGreen = Color(red: 0.67, green: 0.86, blue: 0.76)
    static let pastelOrange = Color(red: 1.0, green: 0.80, blue: 0.62)

    static let pastelPurpleDeep = Color(red: 0.55, green: 0.42, blue: 0.78)
    static let pastelGreenDeep = Color(red: 0.32, green: 0.62, blue: 0.48)
    static let pastelOrangeDeep = Color(red: 0.86, green: 0.48, blue: 0.22)
}

struct PastelChipButton: View {
    enum Tone { case purple, green, orange }

    let title: String
    let systemImage: String
    var tone: Tone = .purple
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundStyle(AppTheme.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(fill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var fill: Color {
        switch tone {
        case .purple: AppTheme.pastelPurple
        case .green: AppTheme.pastelGreen
        case .orange: AppTheme.pastelOrange
        }
    }
}

struct WaterProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 14
    var size: CGFloat = 180

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.hairline, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    AngularGradient(
                        colors: [
                            AppTheme.pastelGreen,
                            AppTheme.pastelPurple,
                            AppTheme.pastelOrange,
                            AppTheme.pastelGreen
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.45), value: progress)
        }
        .frame(width: size, height: size)
    }
}
