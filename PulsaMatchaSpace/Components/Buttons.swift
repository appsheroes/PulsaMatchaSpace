//
//  Buttons.swift
//  PulsaMatchaSpace
//
//  All reusable buttons, chips, toggles, sliders, the heart icon, and the
//  Spark currency icon. Never inline these in views.
//

import SwiftUI

// MARK: - Primary (matcha gummy arcade)
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: {
            Haptic.medium()
            action()
        }) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                }
                Text(title)
                    .font(Fonts.display(19, .bold))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .foregroundColor(Palette.bg0)
            .padding(.horizontal, 28)
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.pill)
                        .fill(GradientStyle.primary)

                    RoundedRectangle(cornerRadius: Radius.pill)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                        .blendMode(.overlay)

                    RoundedRectangle(cornerRadius: Radius.pill)
                        .trim(from: 0.0, to: 0.5)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.55), .clear],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .blendMode(.plusLighter)
                        .padding(2)
                }
            )
            .neonGlow(color: Palette.green, tight: 18, wide: 40)
            .scaleEffect(pressed ? 0.96 : 1)
        }
        .buttonStyle(PressStyle(pressed: $pressed))
    }
}

// MARK: - Secondary (violet gummy)
struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: {
            Haptic.light()
            action()
        }) {
            Text(title)
                .font(Fonts.display(16, .bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundColor(Palette.ink0)
                .padding(.horizontal, 24)
                .frame(height: 52)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: Radius.pill)
                            .fill(GradientStyle.secondary)
                        RoundedRectangle(cornerRadius: Radius.pill)
                            .stroke(Palette.violetSoft.opacity(0.5), lineWidth: 1.5)
                    }
                )
                .softGlow(color: Palette.violet, radius: 24)
                .scaleEffect(pressed ? 0.96 : 1)
        }
        .buttonStyle(PressStyle(pressed: $pressed))
    }
}

// MARK: - Ghost
struct GhostButton: View {
    let title: String
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: {
            Haptic.light()
            action()
        }) {
            Text(title)
                .font(Fonts.ui(14, .bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundColor(Palette.ink0)
                .padding(.horizontal, 20)
                .frame(height: 52)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: Radius.pill)
                            .fill(Color.white.opacity(0.08))
                        RoundedRectangle(cornerRadius: Radius.pill)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    }
                )
                .scaleEffect(pressed ? 0.96 : 1)
        }
        .buttonStyle(PressStyle(pressed: $pressed))
    }
}

// MARK: - Press style helper
struct PressStyle: ButtonStyle {
    @Binding var pressed: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                withAnimation(.easeOut(duration: 0.15)) { pressed = newValue }
            }
    }
}

// MARK: - Icon button (gear, back, plus)
struct IconButton: View {
    let systemName: String
    var tint: Color = Palette.ink0
    var size: CGFloat = 44
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptic.light()
            action()
        }) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(tint)
                .frame(width: size, height: size)
                .background(
                    ZStack {
                        Circle().fill(Color.white.opacity(0.08))
                        Circle().stroke(Color.white.opacity(0.12), lineWidth: 1)
                    }
                )
        }
    }
}

// MARK: - Chip
struct Chip: View {
    let text: String
    var leading: AnyView? = nil
    var tint: Color = Palette.ink0
    var bg: Color = Color.white.opacity(0.08)
    var border: Color = Color.white.opacity(0.12)
    var glowColor: Color? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let leading = leading { leading }
            Text(text)
                .font(Fonts.display(14, .bold))
                .foregroundColor(tint)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .frame(height: 40)
        .background(
            ZStack {
                Capsule().fill(bg)
                Capsule().stroke(border, lineWidth: 1)
            }
        )
        .modifier(OptionalGlow(color: glowColor))
    }
}

private struct OptionalGlow: ViewModifier {
    let color: Color?
    func body(content: Content) -> some View {
        if let color = color {
            content.softGlow(color: color, radius: 14, opacity: 0.35)
        } else {
            content
        }
    }
}

// MARK: - Sparks Chip (currency)
struct SparksChip: View {
    let amount: Int

    var body: some View {
        HStack(spacing: 6) {
            SparkIcon(size: 18)
            Text("\(amount)")
                .font(Fonts.display(15, .bold))
                .foregroundColor(Palette.greenSoft)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(
            ZStack {
                Capsule().fill(Palette.green.opacity(0.08))
                Capsule().stroke(Palette.green.opacity(0.4), lineWidth: 1)
            }
        )
        .softGlow(color: Palette.green, radius: 14, opacity: 0.25)
    }
}

// MARK: - Heart (lives)
struct HeartIcon: View {
    let isActive: Bool
    var size: CGFloat = 22

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: size, weight: .bold))
            .foregroundColor(isActive ? Palette.magenta : Color.white.opacity(0.12))
            .softGlow(color: isActive ? Palette.magenta : .clear, radius: 10, opacity: isActive ? 0.8 : 0)
            .frame(width: 26, height: 26)
    }
}

// MARK: - Spark icon (4-point sparkle — Sparks currency)
struct SparkShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let cx = w / 2, cy = h / 2
        var p = Path()
        p.move(to: CGPoint(x: cx, y: 0))
        p.addQuadCurve(to: CGPoint(x: w, y: cy),
                       control: CGPoint(x: cx + w * 0.13, y: cy - h * 0.13))
        p.addQuadCurve(to: CGPoint(x: cx, y: h),
                       control: CGPoint(x: cx + w * 0.13, y: cy + h * 0.13))
        p.addQuadCurve(to: CGPoint(x: 0, y: cy),
                       control: CGPoint(x: cx - w * 0.13, y: cy + h * 0.13))
        p.addQuadCurve(to: CGPoint(x: cx, y: 0),
                       control: CGPoint(x: cx - w * 0.13, y: cy - h * 0.13))
        p.closeSubpath()
        return p
    }
}

struct SparkIcon: View {
    var size: CGFloat = 24

    var body: some View {
        SparkShape()
            .fill(
                LinearGradient(
                    colors: [Palette.greenSoft, Palette.green, Palette.greenDeep],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .overlay(SparkShape().stroke(Color.white.opacity(0.65), lineWidth: 0.7))
            .frame(width: size, height: size)
            .softGlow(color: Palette.green, radius: size * 0.35, opacity: 0.6)
    }
}

// MARK: - Neon Toggle
struct NeonToggle: View {
    @Binding var isOn: Bool
    var tint: Color

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? LinearGradient(colors: [tint, tint.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                           : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .leading, endPoint: .trailing))
            Capsule()
                .stroke(isOn ? tint.opacity(0.7) : Color.white.opacity(0.1), lineWidth: 1)

            Circle()
                .fill(Color.white)
                .frame(width: 24, height: 24)
                .padding(3)
                .softGlow(color: isOn ? tint : .clear, radius: 8, opacity: 0.6)
        }
        .frame(width: 52, height: 30)
        .softGlow(color: isOn ? tint : .clear, radius: 12, opacity: 0.4)
        .onTapGesture {
            Haptic.light()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                isOn.toggle()
            }
        }
    }
}

// MARK: - Neon Slider
struct NeonSlider: View {
    @Binding var value: Double
    var tint: Color

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 6)

                Capsule()
                    .fill(tint)
                    .frame(width: max(0, w * CGFloat(value)), height: 6)
                    .softGlow(color: tint, radius: 10, opacity: 0.5)

                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .softGlow(color: tint, radius: 8, opacity: 0.7)
                    .offset(x: max(0, w * CGFloat(value)) - 8)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        let newValue = max(0, min(1, g.location.x / w))
                        value = Double(newValue)
                    }
            )
        }
    }
}
