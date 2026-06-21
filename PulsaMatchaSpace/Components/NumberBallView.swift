//
//  NumberBallView.swift
//  PulsaMatchaSpace
//
//  Pure-SwiftUI vector art for the gameplay objects:
//  - NumberBallView : a glowing, colored, numbered ball
//  - VoidOrbView    : a dark hazard orb (tap-trap)
//  - PulseOrbView   : the branded pulsing hero orb (Home / Loading)
//  - PopRingView    : the shockwave burst played when a ball is popped
//

import SwiftUI

// MARK: - Numbered ball
struct NumberBallView: View {
    let number: Int
    let color: Color
    var size: CGFloat = 60
    var isTarget: Bool = false
    /// 0...1 phase from a TimelineView, used to animate the target highlight.
    var pulse: CGFloat = 0

    var body: some View {
        ZStack {
            if isTarget {
                Circle()
                    .stroke(Palette.ink0.opacity(0.9), lineWidth: 2)
                    .frame(width: size * (1.16 + 0.20 * pulse),
                           height: size * (1.16 + 0.20 * pulse))
                    .opacity(Double(1 - pulse * 0.75))
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            color,
                            color.opacity(0.55),
                            Color.black.opacity(0.35)
                        ],
                        center: UnitPoint(x: 0.38, y: 0.32),
                        startRadius: 0,
                        endRadius: size * 0.62
                    )
                )

            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 1.2)

            // Inner "token" ring — a signature look distinct from a plain orb.
            Circle()
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
                .frame(width: size * 0.7, height: size * 0.7)

            Ellipse()
                .fill(Color.white.opacity(0.55))
                .frame(width: size * 0.26, height: size * 0.15)
                .offset(x: -size * 0.16, y: -size * 0.22)

            Text("\(number)")
                .font(Fonts.display(size * 0.5, .heavy))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                .minimumScaleFactor(0.4)
                .lineLimit(1)
        }
        .frame(width: size, height: size)
        .neonGlowUnclipped(color: color,
                           tight: isTarget ? 16 : 9,
                           wide: isTarget ? 32 : 18)
        .scaleEffect(isTarget ? (1 + 0.05 * pulse) : 1)
    }
}

// MARK: - Void hazard orb
struct VoidOrbView: View {
    var size: CGFloat = 54
    /// Rotation (degrees) driven externally so the swirl turns without
    /// per-view @State (these are rebuilt every frame inside a TimelineView).
    var spin: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: 0x1A0E2A), .black, .black],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )

            Circle()
                .stroke(Palette.red.opacity(0.85), lineWidth: 2)

            Circle()
                .stroke(Palette.violet.opacity(0.45), lineWidth: 6)
                .blur(radius: 5)

            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .trim(from: 0, to: 0.55)
                    .stroke(Palette.magenta.opacity(0.55), lineWidth: 1.2)
                    .frame(width: size * (0.32 + 0.18 * CGFloat(i)),
                           height: size * (0.32 + 0.18 * CGFloat(i)))
                    .rotationEffect(.degrees(spin + Double(i) * 55))
            }
        }
        .frame(width: size, height: size)
        .neonGlowUnclipped(color: Palette.red, tight: 8, wide: 20)
    }
}

// MARK: - Pulse hero orb (continuously emits rings — loops forever)
struct PulseOrbView: View {
    var color: Color = Palette.green
    var size: CGFloat = 160

    var body: some View {
        TimelineView(.animation) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    let phase = ((t / 2.4) + Double(i) / 3.0).truncatingRemainder(dividingBy: 1.0)
                    Circle()
                        .stroke(color.opacity(1.0 - phase), lineWidth: 2)
                        .frame(width: size * (0.7 + CGFloat(phase) * 1.2),
                               height: size * (0.7 + CGFloat(phase) * 1.2))
                        .opacity(1.0 - phase)
                }

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white, color, color.opacity(0.4), Palette.bg0],
                            center: UnitPoint(x: 0.4, y: 0.35),
                            startRadius: 0,
                            endRadius: size * 0.5
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay(
                        Ellipse()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: size * 0.24, height: size * 0.14)
                            .offset(x: -size * 0.15, y: -size * 0.2)
                    )
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                    .neonGlowUnclipped(color: color, tight: 24, wide: 60)
            }
        }
        .frame(width: size * 1.9, height: size * 1.9)
    }
}

// MARK: - Pop shockwave
struct PopRingView: View {
    let color: Color
    /// 0...1 lifetime progress.
    let progress: Double
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .stroke(color, lineWidth: max(0.5, 3 * (1 - progress)))
                .frame(width: size * (0.4 + progress * 1.6),
                       height: size * (0.4 + progress * 1.6))
                .opacity(1 - progress)

            ForEach(0..<6, id: \.self) { i in
                let a = Double(i) / 6.0 * 2.0 * .pi
                Circle()
                    .fill(color)
                    .frame(width: 4, height: 4)
                    .offset(x: CGFloat(cos(a)) * size * CGFloat(0.3 + progress * 0.8),
                            y: CGFloat(sin(a)) * size * CGFloat(0.3 + progress * 0.8))
                    .opacity(1 - progress)
            }
        }
        .softGlow(color: color, radius: 14, opacity: (1 - progress) * 0.7)
    }
}
