//
//  Theme.swift
//  PulsaMatchaSpace
//
//  Neon "matcha space" design tokens. Deep teal-navy cosmic backgrounds,
//  a matcha-green hero accent, and a full neon rainbow used to color the
//  numbered balls.
//

import SwiftUI

// MARK: - Palette
enum Palette {
    static let bg0  = Color(hex: 0x05101A)
    static let bg1  = Color(hex: 0x0A1A28)
    static let bg2  = Color(hex: 0x102438)
    static let bg3  = Color(hex: 0x16324A)

    // Hero accent — matcha green
    static let green      = Color(hex: 0x6BFFB0)
    static let greenSoft  = Color(hex: 0xB6FFD6)
    static let greenDeep  = Color(hex: 0x1FB877)

    static let cyan       = Color(hex: 0x4DE6FF)
    static let violet     = Color(hex: 0x9B6BFF)
    static let violetSoft = Color(hex: 0xC9B0FF)
    static let violetDeep = Color(hex: 0x5E2BD9)
    static let magenta    = Color(hex: 0xFF5BC8)
    static let yellow     = Color(hex: 0xFFD84D)
    static let yellowSoft = Color(hex: 0xFFEFA3)
    static let orange     = Color(hex: 0xFF9F45)
    static let blue       = Color(hex: 0x5B8CFF)
    static let red        = Color(hex: 0xFF5E6C)

    static let ink0 = Color.white
    static let ink1 = Color.white.opacity(0.80)
    static let ink2 = Color.white.opacity(0.55)
    static let ink3 = Color.white.opacity(0.32)

    /// Distinct neon colors for the numbered balls, indexed by number.
    static let ballColors: [Color] = [
        green, cyan, magenta, yellow, violet, orange, blue, red
    ]

    /// Color for a given ball number (1-based).
    static func ballColor(_ number: Int) -> Color {
        ballColors[(max(1, number) - 1) % ballColors.count]
    }
}

// MARK: - Radii
enum Radius {
    static let xs: CGFloat = 8
    static let sm: CGFloat = 14
    static let md: CGFloat = 20
    static let lg: CGFloat = 28
    static let xl: CGFloat = 36
    static let pill: CGFloat = 9999
}

// MARK: - Spacing
enum Spacing {
    static let tight: CGFloat = 8
    static let gap: CGFloat = 12
    static let list: CGFloat = 14
    static let section: CGFloat = 20
    static let screenH: CGFloat = 16
}

// MARK: - Fonts
enum Fonts {
    static func display(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        Font.system(size: size, weight: weight, design: .rounded)
    }

    static func ui(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        Font.system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Hex Color
extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

// MARK: - Glow recipe (two-layer shadow)
extension View {
    /// Two-layer neon glow: tight inner + wide halo.
    func neonGlow(color: Color, tight: CGFloat = 16, wide: CGFloat = 36) -> some View {
        self
            .shadow(color: color.opacity(0.80), radius: tight)
            .shadow(color: color.opacity(0.40), radius: wide)
    }

    /// Same as `neonGlow`, but prevents the glow from being clipped to the
    /// view's rectangular bounds. Expands the render bounds before applying
    /// shadows, then restores the original layout with negative padding.
    func neonGlowUnclipped(
        color: Color,
        tight: CGFloat = 16,
        wide: CGFloat = 36,
        extraPadding: CGFloat? = nil
    ) -> some View {
        let pad = extraPadding ?? (wide + 10)
        return self
            .padding(pad)
            .shadow(color: color.opacity(0.80), radius: tight)
            .shadow(color: color.opacity(0.40), radius: wide)
            .padding(-pad)
    }

    /// Subtle outer glow for chips/borders.
    func softGlow(color: Color, radius: CGFloat = 16, opacity: Double = 0.35) -> some View {
        self.shadow(color: color.opacity(opacity), radius: radius)
    }
}

// MARK: - Gradients
enum GradientStyle {
    static let primary = LinearGradient(
        colors: [Palette.green, Palette.greenDeep],
        startPoint: .top, endPoint: .bottom
    )

    static let secondary = LinearGradient(
        colors: [Palette.violet, Palette.violetDeep],
        startPoint: .top, endPoint: .bottom
    )

    static let card = LinearGradient(
        colors: [
            Color(hex: 0x12283C, opacity: 0.92),
            Color(hex: 0x0A1A28, opacity: 0.92)
        ],
        startPoint: .top, endPoint: .bottom
    )

    static let fieldFill = LinearGradient(
        colors: [
            Color(hex: 0x0E2236, opacity: 0.88),
            Color(hex: 0x070F1A, opacity: 0.96)
        ],
        startPoint: .top, endPoint: .bottom
    )

    static let backgroundBase = LinearGradient(
        colors: [Palette.bg0, Palette.bg1, Palette.bg0],
        startPoint: .top, endPoint: .bottom
    )

    static let timerPill = LinearGradient(
        colors: [
            Color(hex: 0x1FB877, opacity: 0.30),
            Color(hex: 0x16324A, opacity: 0.20)
        ],
        startPoint: .top, endPoint: .bottom
    )

    static func logoTitle() -> LinearGradient {
        LinearGradient(
            colors: [Palette.ink0, Palette.greenSoft, Palette.green],
            startPoint: .top, endPoint: .bottom
        )
    }
}
