import SwiftUI

struct MoodOption: Identifiable {
    let id = UUID()
    let emoji: String
    let label: String
    let color: Color       // pastel background
    let textColor: Color   // dark saturated text
}

// MARK: - Mood Options (anime pastel palette)

let moodOptions: [MoodOption] = [
    MoodOption(emoji: "😊", label: "开心", color: DesignSystem.moodHappy, textColor: DesignSystem.moodHappyText),
    MoodOption(emoji: "😌", label: "平静", color: DesignSystem.moodCalm, textColor: DesignSystem.moodCalmText),
    MoodOption(emoji: "😢", label: "难过", color: DesignSystem.moodSad, textColor: DesignSystem.moodSadText),
    MoodOption(emoji: "🤩", label: "兴奋", color: DesignSystem.moodExcited, textColor: DesignSystem.moodExcitedText),
    MoodOption(emoji: "😰", label: "焦虑", color: DesignSystem.moodAnxious, textColor: DesignSystem.moodAnxiousText),
]

private let moodKeywords: [String: String] = [
    "😊": "阳光 咖啡 周末 聚会 开心 笑",
    "😌": "雨 安静 思考 一个人 散步",
    "😢": "哭 分手 失去 难过 下雨天",
    "🤩": "旅行 冒险 挑战 演唱会 Party",
    "😰": "累 压力 加班 崩溃 焦虑 忙",
]

func recommendMood(for text: String) -> MoodOption? {
    let trimmed = text.lowercased()
    for option in moodOptions {
        guard let keywords = moodKeywords[option.emoji] else { continue }
        for keyword in keywords.components(separatedBy: " ") {
            if trimmed.contains(keyword.lowercased()) {
                return option
            }
        }
    }
    return nil
}

func recommendMoodFromColor(_ image: UIImage) -> MoodOption? {
    guard let (h, s, l) = image.hslFromAverageColor() else { return nil }

    // Updated HSL targets to match the new anime pastel palette
    let targets: [(emoji: String, h: CGFloat, s: CGFloat, l: CGFloat)] = [
        ("😊", 48,  0.75, 0.82),   // cream yellow #FFE8A1
        ("😌", 185, 0.50, 0.80),   // mint blue #B3E0E5
        ("😢", 262, 0.28, 0.84),   // misty purple #D1C4E9
        ("🤩", 6,   0.65, 0.85),   // coral pink #FFB7B2
        ("😰", 356, 0.55, 0.92),   // champagne pink #FADADD
    ]

    var bestEmoji: String? = nil
    var bestDistance: CGFloat = .infinity

    for t in targets {
        let dh = min(abs(h - t.h), 360 - abs(h - t.h))
        let ds = (s - t.s) * 100
        let dl = (l - t.l) * 100
        let distance = sqrt(dh * dh + ds * ds + dl * dl)
        if distance < bestDistance {
            bestDistance = distance
            bestEmoji = t.emoji
        }
    }

    guard let emoji = bestEmoji else { return nil }
    return moodOptions.first { $0.emoji == emoji }
}

/// Returns the mood's pastel background color (for lines, fills, visual indicators).
func colorForMood(_ emoji: String?) -> Color {
    guard let emoji else { return DesignSystem.textSecondary }
    return moodOptions.first { $0.emoji == emoji }?.color ?? DesignSystem.textSecondary
}

/// Returns the mood's dark saturated text color (for labels, tags on light backgrounds).
func textColorForMood(_ emoji: String?) -> Color {
    guard let emoji else { return DesignSystem.textSecondary }
    return moodOptions.first { $0.emoji == emoji }?.textColor ?? DesignSystem.textSecondary
}

// MARK: - Mood English Names

private let moodEnglishMap: [String: String] = [
    "😊": "happy",
    "😌": "calm",
    "😢": "sad",
    "🤩": "excited",
    "😰": "anxious",
]

func moodEnglishName(for emoji: String?) -> String {
    guard let emoji else { return "" }
    return moodEnglishMap[emoji] ?? emoji
}

// MARK: - Shared Date Formatters

/// English date-time: "June 29, 2026 · 2:30 PM"
func formatDateEnglish(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US")
    dateFormatter.dateFormat = "MMMM d, yyyy"
    let dateStr = dateFormatter.string(from: date)

    dateFormatter.dateFormat = "h:mm a"
    let timeStr = dateFormatter.string(from: date)

    return "\(dateStr) · \(timeStr)"
}

/// Chinese date-time: 2026年6月29日 · 午后 2:30
func formatDateChinese(_ date: Date) -> String {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    let year = components.year ?? 2026
    let month = components.month ?? 1
    let day = components.day ?? 1
    let hour = components.hour ?? 0
    let minute = components.minute ?? 0

    let period: String
    switch hour {
    case 0...5:   period = "凌晨"
    case 6...11:  period = "上午"
    case 12:      period = "中午"
    case 13...17: period = "午后"
    case 18...23: period = "晚上"
    default:      period = ""
    }

    let displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
    let timeStr = String(format: "%d:%02d", displayHour, minute)
    return "\(year)年\(month)月\(day)日 · \(period) \(timeStr)"
}

// MARK: - Mood Selector (soft pastel pill row)

struct MoodSelector: View {
    @Binding var selectedEmoji: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mood")
                .font(.caption)
                .foregroundColor(DesignSystem.textSecondary)
                .tracking(DesignSystem.bodyTracking)

            HStack(spacing: 10) {
                ForEach(moodOptions) { option in
                    let isSelected = selectedEmoji == option.emoji
                    let englishName = moodEnglishName(for: option.emoji)

                    Button {
                        withAnimation(DesignSystem.fadeEase) {
                            selectedEmoji = isSelected ? nil : option.emoji
                        }
                    } label: {
                        Text(englishName)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(isSelected ? .medium : .regular)
                            .foregroundColor(isSelected ? option.textColor : DesignSystem.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusSmall)
                                    .fill(isSelected ? option.color.opacity(0.6) : Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusSmall)
                                    .stroke(isSelected ? option.color : DesignSystem.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .animation(DesignSystem.fadeEase, value: selectedEmoji)
    }
}

// MARK: - Mood Recommendation Hint

struct MoodRecommendationHint: View {
    let emoji: String
    let label: String
    let moodColor: Color
    var onAdopt: () -> Void

    var body: some View {
        Button {
            withAnimation(DesignSystem.fadeEase) {
                onAdopt()
            }
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(moodColor)
                    .frame(width: 8, height: 8)

                Text("Suggested: \(moodEnglishName(for: emoji))")
                    .font(.caption)
                    .foregroundColor(DesignSystem.textSecondary)
                    .tracking(DesignSystem.bodyTracking)

                Spacer()

                Text("Apply")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.accent)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusSmall)
                    .fill(DesignSystem.hintBackground.opacity(0.8))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty Archive View (soft anime-style)

/// Shared empty-state component — soft bordered rounded square with SF Symbol.
/// Used by Diary, Photos, and Film list views.
struct EmptyArchiveView: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusLarge)
                    .stroke(DesignSystem.border, lineWidth: 1)
                    .frame(width: 80, height: 80)

                Image(systemName: icon)
                    .font(.system(size: 30, weight: .thin))
                    .foregroundColor(DesignSystem.textSecondary.opacity(0.4))
            }
            .shadow(color: DesignSystem.cardShadowColor, radius: DesignSystem.cardShadowRadius, x: 0, y: DesignSystem.cardShadowY)

            Text(title)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(DesignSystem.textSecondary)
                .tracking(DesignSystem.bodyTracking)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

// MARK: - Record Row (diary archive card)

/// Archive-style card with rounded corners, soft shadow, and 1px left mood-coloured line.
/// Anime lightness: generous padding, rounded mood tag, deliberate press spring.
struct RecordRowView: View {
    let record: Record

    @State private var isPressed = false
    @State private var hapticTrigger = 0

    var body: some View {
        HStack(spacing: 0) {
            // Content area — generous whitespace
            VStack(alignment: .leading, spacing: 8) {
                // Top row: content + mood tag
                HStack(alignment: .top, spacing: 8) {
                    Text(record.content)
                        .font(DesignSystem.body)
                        .foregroundColor(DesignSystem.textBody)
                        .lineSpacing(DesignSystem.bodyLineSpacing)
                        .tracking(DesignSystem.bodyTracking)
                        .lineLimit(2)

                    Spacer(minLength: 8)

                    // Mood tag — rounded, pastel fill + dark text
                    if let mood = record.mood {
                        Text(moodEnglishName(for: mood))
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(textColorForMood(mood))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusSmall)
                                    .fill(colorForMood(mood).opacity(0.5))
                            )
                    }
                }

                // Bottom row: timestamp right-aligned
                HStack {
                    Spacer()
                    Text(formatDateEnglish(record.createdAt))
                        .font(.caption2)
                        .foregroundColor(DesignSystem.textSecondary)
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, DesignSystem.screenPadding)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusLarge)
                .fill(DesignSystem.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusLarge)
                .stroke(DesignSystem.border, lineWidth: 1)
        )
        .shadow(
            color: DesignSystem.cardShadowColor,
            radius: DesignSystem.cardShadowRadius,
            x: 0,
            y: DesignSystem.cardShadowY
        )
        .overlay(alignment: .leading) {
            // 1px mood-coloured vertical line — left edge
            RoundedRectangle(cornerRadius: 1)
                .fill(colorForMood(record.mood))
                .frame(width: DesignSystem.moodLineWidth)
                .padding(.vertical, 12)
                .padding(.leading, 0)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(DesignSystem.pressSpring, value: isPressed)
        .sensoryFeedback(.impact(weight: .light), trigger: hapticTrigger)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
            if pressing { hapticTrigger += 1 }
        }, perform: {})
    }
}
