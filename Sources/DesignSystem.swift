import SwiftUI

/// LifeChronicle Global Design System — Old Money Aesthetic (Prada-esque cool luxury)
///
/// ## Typography
/// Titles use iOS built-in Serif (New York). For Playfair Display:
/// 1. Download PlayfairDisplay-*.ttf from https://fonts.google.com/specimen/Playfair+Display
/// 2. Drag into Xcode project, add to Info.plist "Fonts provided by application"
/// 3. Use `Font.custom("PlayfairDisplay-Regular", size: ...)`
///
/// ## App Icon
/// Core element: Silver uppercase serif "R" on deep navy blue background.
/// - **Letterform**: Serif "R" (Playfair Display or similar Didone), metallic silver gradient
/// - **Background**: Deep navy blue #1D3557 (matches `accent`)
/// - **Treatment**: Subtle metallic sheen, crisp edges, no shadow, no gloss
/// - **Launch Screen**: Solid #1D3557 background with centered silver "R" wordmark
/// - **Generate at**: 1024×1024 px PNG (no alpha), iOS auto-scales to all required sizes
/// - **Silver gradient recipe**: `linear-gradient(135deg, #E8E8EA 0%, #C4C4C8 50%, #A8A8AE 100%)`
///
/// ## Animation Philosophy
/// Old Money motion is deliberate, never bouncy. Springs have high damping (≥0.75).
/// Entrances are staggered but restrained. Nothing pops — everything breathes.
enum DesignSystem {

    // MARK: - Background Colors

    /// Main background — cool silver-white (Prada paper-bag tone)
    static let background = Color(red: 245/255, green: 245/255, blue: 247/255)  // #F5F5F7
    /// Card surface — pure white
    static let cardBackground = Color.white  // #FFFFFF
    /// Dark mode / immersive viewer
    static let darkBackground = Color(red: 28/255, green: 28/255, blue: 30/255)
    /// Deprecated input field background (prefer `editorBackground`)
    static let inputBackground = Color(red: 238/255, green: 238/255, blue: 240/255)  // #EEEEF0
    /// Text editor / input area — warm paper, slightly deeper than `background`
    static let editorBackground = Color(red: 234/255, green: 232/255, blue: 227/255)  // #EAE8E3
    /// Mood recommendation hint background — cool light grey
    static let hintBackground = Color(red: 232/255, green: 232/255, blue: 235/255)  // #E8E8EB

    // MARK: - Text Colors

    /// Primary headline — near black
    static let textPrimary = Color(red: 28/255, green: 28/255, blue: 28/255)   // #1C1C1C
    /// Body text — dark grey
    static let textBody = Color(red: 58/255, green: 58/255, blue: 60/255)      // #3A3A3C
    /// Secondary / captions — medium grey
    static let textSecondary = Color(red: 142/255, green: 142/255, blue: 147/255)  // #8E8E93

    // MARK: - Mood Colors (desaturated Old Money palette)

    /// Happy — warm sand
    static let moodHappy = Color(red: 212/255, green: 184/255, blue: 149/255)   // #D4B895
    /// Calm — muted blue-grey
    static let moodCalm = Color(red: 122/255, green: 139/255, blue: 153/255)    // #7A8B99
    /// Sad — cool grey
    static let moodSad = Color(red: 156/255, green: 163/255, blue: 175/255)     // #9CA3AF
    /// Excited — deep burgundy
    static let moodExcited = Color(red: 139/255, green: 90/255, blue: 90/255)   // #8B5A5A
    /// Anxious — misty purple
    static let moodAnxious = Color(red: 180/255, green: 167/255, blue: 182/255)  // #B4A7B6

    // MARK: - Accent & Embellishment

    /// Prada blue — deep navy (primary buttons, navigation accent)
    static let accent = Color(red: 29/255, green: 53/255, blue: 87/255)         // #1D3557
    /// Warm gold — mood dots, accent lines (used sparingly)
    static let gold = Color(red: 201/255, green: 169/255, blue: 110/255)        // #C9A96E

    /// App icon silver — metallic light silver for icon letterform reference
    static let iconSilver = Color(red: 212/255, green: 212/255, blue: 214/255)  // #D4D4D6

    // MARK: - Borders

    /// Card / element hairline border — 1px
    static let border = Color(red: 229/255, green: 229/255, blue: 229/255)      // #E5E5E5
    /// Editor focused border — navy
    static let borderFocused = accent

    // MARK: - Typography

    /// Large title — 28pt Bold Serif (New York), tracking +2
    static let largeTitle = Font.system(size: 28, weight: .bold, design: .serif)
    /// Section title — 20pt Semibold
    static let title = Font.system(size: 20, weight: .semibold)
    /// Body — 15pt Regular
    static let body = Font.system(size: 15, weight: .regular)

    /// Body line spacing addition (in points)
    static let bodyLineSpacing: CGFloat = 9
    /// Body line height multiplier (~1.6× at 15pt)
    static let bodyLineHeight: CGFloat = 1.6
    /// Body letter spacing
    static let bodyTracking: CGFloat = 0.3

    // MARK: - Corner Radius

    /// Sharp minimal — cards, panels
    static let cornerRadiusLarge: CGFloat = 2
    /// Small elements — 2pt micro-radius
    static let cornerRadiusSmall: CGFloat = 2
    /// Buttons — 2pt micro-radius
    static let cornerRadiusButton: CGFloat = 2

    // MARK: - Shadows

    /// Old Money aesthetic uses zero shadows — hierarchy via whitespace + borders

    // MARK: - Spacing & Sizing

    /// Screen horizontal padding — 24pt
    static let screenPadding: CGFloat = 24
    /// Standard element spacing — 16pt
    static let spacing: CGFloat = 16
    /// Gallery home card height — 78pt
    static let cardHeight: CGFloat = 78
    /// Gallery home card gap — 12pt
    static let cardSpacing: CGFloat = 12
    /// Standard button height — 44pt (HIG minimum touch target)
    static let buttonHeight: CGFloat = 44
    /// Gold accent line width — 1px (refined)
    static let goldLineWidth: CGFloat = 1
    /// Gold accent line height — 28pt
    static let goldLineHeight: CGFloat = 28
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

/// Old Money silver-white background — solid colour, no texture
struct OldMoneyBackground: View {
    var body: some View {
        DesignSystem.background
            .ignoresSafeArea()
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
