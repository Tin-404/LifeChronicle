import SwiftUI

/// Ricky Global Design System — Anime-Inspired Light Blue Aesthetic
///
/// A lighter, airier palette with rounded typography, pastel mood colors,
/// and soft blue shadows. Feels like a Studio Ghibli sky — clean, hopeful, warm.
///
/// ## Typography
/// Rounded system fonts throughout — `.system(.title, design: .rounded)`.
/// Slightly tighter tracking (0.2) keeps the airy feel without losing readability.
///
/// ## Color Strategy
/// Restrained: tinted mist-blue neutrals with a single clear-sky accent.
/// Mood colors use pastel backgrounds with darker saturated text for tags and indicators.
///
/// ## App Icon
/// Core element: Silver uppercase serif "R" on deep navy blue background.
/// (Unchanged — the icon is the anchor identity mark.)
///
/// ## Animation Philosophy
/// Light, deliberate springs. Same restraint as before but adapted to a softer palette.
/// Entrances are staggered, fades are smooth, nothing pops aggressively.
enum DesignSystem {

    // MARK: - Background Colors

    /// Main background — mist blue, like morning fog (#F0F4F8)
    static let background = Color(red: 240/255, green: 244/255, blue: 248/255)
    /// Card surface — pure white
    static let cardBackground = Color.white
    /// Dark mode / immersive viewer
    static let darkBackground = Color(red: 28/255, green: 28/255, blue: 30/255)
    /// Deprecated input field background (prefer `editorBackground`)
    static let inputBackground = Color(red: 228/255, green: 234/255, blue: 240/255)
    /// Text editor / input area — slightly deeper mist, subtle definition
    static let editorBackground = Color(red: 228/255, green: 234/255, blue: 240/255)  // #E4EAF0
    /// Mood recommendation hint background
    static let hintBackground = Color(red: 226/255, green: 232/255, blue: 238/255)    // #E2E8EE

    // MARK: - Text Colors

    /// Primary headline — deep navy-blue ink (#102A43)
    static let textPrimary = Color(red: 16/255, green: 42/255, blue: 67/255)
    /// Body text — slate blue (#334E68)
    static let textBody = Color(red: 51/255, green: 78/255, blue: 104/255)
    /// Secondary / captions — soft steel blue (#627D98)
    static let textSecondary = Color(red: 98/255, green: 125/255, blue: 152/255)

    // MARK: - Mood Colors (anime pastel palette)

    /// Happy — cream yellow bg (#FFE8A1) with mikan-orange text
    static let moodHappy = Color(red: 255/255, green: 232/255, blue: 161/255)
    static let moodHappyText = Color(red: 184/255, green: 134/255, blue: 14/255)       // #B8860E

    /// Calm — mint blue bg (#B3E0E5) with deep cyan text
    static let moodCalm = Color(red: 179/255, green: 224/255, blue: 229/255)
    static let moodCalmText = Color(red: 26/255, green: 107/255, blue: 122/255)         // #1A6B7A

    /// Sad — misty purple bg (#D1C4E9) with deep purple text
    static let moodSad = Color(red: 209/255, green: 196/255, blue: 233/255)
    static let moodSadText = Color(red: 74/255, green: 63/255, blue: 138/255)           // #4A3F8A

    /// Excited — coral pink bg (#FFB7B2) with deep red text
    static let moodExcited = Color(red: 255/255, green: 183/255, blue: 178/255)
    static let moodExcitedText = Color(red: 155/255, green: 48/255, blue: 48/255)       // #9B3030

    /// Anxious — champagne pink bg (#FADADD) with taupe text
    static let moodAnxious = Color(red: 250/255, green: 218/255, blue: 221/255)
    static let moodAnxiousText = Color(red: 92/255, green: 64/255, blue: 64/255)        // #5C4040

    // MARK: - Accent & Embellishment

    /// Clear sky blue — primary buttons, links, accent lines (#2B8EC9)
    static let accent = Color(red: 43/255, green: 142/255, blue: 201/255)

    // Keep legacy token for SplashView which retains Old Money aesthetic
    /// Warm gold — SplashView accent (preserved)
    static let gold = Color(red: 201/255, green: 169/255, blue: 110/255)  // #C9A96E

    // MARK: - Borders

    /// Card / element hairline border — pale blue-grey (#D9E2EC)
    static let border = Color(red: 217/255, green: 226/255, blue: 236/255)
    /// Editor focused border — sky blue
    static let borderFocused = accent

    // MARK: - Typography

    /// Large title — 28pt Bold Rounded
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    /// Section title — 20pt Semibold Rounded
    static let title = Font.system(.title3, design: .rounded).weight(.semibold)
    /// Body — 15pt Regular Rounded
    static let body = Font.system(.body, design: .rounded)

    /// Body line spacing addition (in points)
    static let bodyLineSpacing: CGFloat = 8
    /// Body line height multiplier
    static let bodyLineHeight: CGFloat = 1.6
    /// Body letter spacing
    static let bodyTracking: CGFloat = 0.2

    // MARK: - Corner Radius

    /// Cards, panels — soft rounded
    static let cornerRadiusLarge: CGFloat = 16
    /// Small elements — pills, tags
    static let cornerRadiusSmall: CGFloat = 8
    /// Buttons
    static let cornerRadiusButton: CGFloat = 8

    // MARK: - Shadows

    /// Very faint blue-tinted shadow — gentle depth, not heavy
    static let cardShadowColor = Color.black.opacity(0.03)
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat = 2

    /// Convenience modifier-style view for card shadow
    static func cardShadow<V: View>(_ view: V) -> some View {
        view.shadow(color: cardShadowColor, radius: cardShadowRadius, x: 0, y: cardShadowY)
    }

    // MARK: - Spacing & Sizing

    /// Screen horizontal padding — 20pt
    static let screenPadding: CGFloat = 20
    /// Standard element spacing — 14pt
    static let spacing: CGFloat = 14
    /// Gallery home card height — 78pt
    static let cardHeight: CGFloat = 78
    /// Gallery home card gap — 12pt
    static let cardSpacing: CGFloat = 12
    /// Standard button height — 44pt (HIG minimum touch target)
    static let buttonHeight: CGFloat = 44
    /// Accent line width — 1px (refined)
    static let accentLineWidth: CGFloat = 1
    /// Accent line height — 28pt
    static let accentLineHeight: CGFloat = 28
    /// Mood indicator line width (list left-edge) — 1px
    static let moodLineWidth: CGFloat = 1

    // MARK: - Animation Presets

    /// Restrained spring for press effects — deliberate, not bouncy
    static let pressSpring = Animation.spring(response: 0.35, dampingFraction: 0.75)
    /// Entrance spring for staggered list items
    static let entranceSpring = Animation.spring(response: 0.45, dampingFraction: 0.78)
    /// Standard ease-out for fades / opacity transitions
    static let fadeEase = Animation.easeOut(duration: 0.3)
    /// Stagger delay per list item (seconds)
    static let staggerDelay: Double = 0.06
}

// MARK: - Global Background

/// Mist-blue background — solid colour, no texture
struct MistBlueBackground: View {
    var body: some View {
        DesignSystem.background
            .ignoresSafeArea()
    }
}

// MARK: - Card Style Modifier

extension View {
    /// Apply the standard Ricky card style: white bg, blue-grey border, soft shadow, 16pt radius.
    func rickyCard() -> some View {
        self
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
    }
}

// MARK: - iOS 18 Navigation Transition Helpers

extension View {
    /// Conditionally apply `.matchedTransitionSource` on iOS 18+, no-op earlier.
    @ViewBuilder
    func zoomSource(id: String, namespace: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) {
            self.matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }

    /// Conditionally apply `.navigationTransition(.zoom(...))` on iOS 18+, no-op earlier.
    @ViewBuilder
    func zoomDestination(sourceID: String, namespace: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) {
            self.navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        } else {
            self
        }
    }
}
