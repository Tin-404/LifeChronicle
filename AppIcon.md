# LifeChronicle — App Icon Design Spec

## Core Concept

A **silver uppercase serif "R"** on a deep navy blue background. Minimal, refined, Old Money — the icon version of a Prada paper bag.

---

## Specifications

| Property | Value |
|----------|-------|
| **Size** | 1024 × 1024 px (iOS auto-scales to all required sizes) |
| **Format** | PNG, no alpha (solid background) |
| **Background** | `#1D3557` (deep navy blue — matches `DesignSystem.accent`) |
| **Letterform** | Uppercase "R", serif (Playfair Display Bold or similar Didone) |
| **Letter colour** | Silver metallic gradient |
| **Corners** | Sharp (no rounded corners — iOS applies its own mask) |

---

## Silver Gradient Recipe

Apply this linear gradient to the "R" letterform:

```
linear-gradient(135deg,
  #E8E8EA   0%,    // bright silver highlight (top-left)
  #C4C4C8  50%,    // mid-tone silver
  #A8A8AE 100%     // deeper shadow silver (bottom-right)
)
```

In CSS/design tool terms: a 135° diagonal gradient from light silver to darker silver, giving the letterform a subtle metallic sheen without looking glossy or 3D.

---

## Visual Layout

```
┌──────────────────────────────────┐
│                                  │
│            #1D3557               │
│         (navy blue)              │
│                                  │
│               R                  │  ← Silver serif "R", centred
│                                  │     ~60% of canvas height
│                                  │
│                                  │
└──────────────────────────────────┘
```

- The "R" should occupy roughly **55–65%** of the canvas height
- Centred both horizontally and vertically
- No additional ornamentation — no border, no glow, no shadow
- The letter itself carries all the visual weight

---

## Launch Screen

For the iOS launch screen (shown before SwiftUI loads):

| Property | Value |
|----------|-------|
| **Background** | Solid `#1D3557` (navy blue) |
| **Content** | Silver "R" wordmark, centred |
| **Size** | ~120pt height on iPhone |

In Xcode:
1. Open `Assets.xcassets` → `AppIcon`
2. Drop the 1024×1024 icon into the "App Store iOS 1024pt" slot
3. Xcode auto-generates all smaller sizes

For the Launch Screen:
1. Create a `Launch Screen.storyboard` in Xcode (`File → New → File → Launch Screen`)
2. Set background to `#1D3557`
3. Add an `UIImageView` with the silver "R" logo, centred
4. Or use a solid colour launch screen via `Info.plist` (simpler)

---

## Generation Checklist

- [ ] Create 1024×1024 canvas, background `#1D3557`
- [ ] Place serif "R" (Playfair Display Bold, ~600pt) in centre
- [ ] Apply 135° silver gradient to "R" letterform
- [ ] Export as PNG (no transparency)
- [ ] Import into Xcode `Assets.xcassets` → `AppIcon`
- [ ] Verify all auto-generated sizes look correct in Xcode
- [ ] Build & run to confirm icon appears on Home Screen

---

## Reference

These colours are defined in code at `Sources/DesignSystem.swift`:
- `accent` = `#1D3557` (navy background)
- `gold` = `#C9A96E` (warm accent — not used in icon, for UI only)
- `iconSilver` = `#D4D4D6` (mid-tone reference point for silver gradient)
