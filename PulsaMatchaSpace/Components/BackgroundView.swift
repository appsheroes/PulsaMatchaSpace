//
//  BackgroundView.swift
//  PulsaMatchaSpace
//
//  Deep-space cosmic backdrop. Heavy gradients + blurred orbs are rasterized
//  via `drawingGroup()` into single GPU textures; the starfield is drawn in
//  one Canvas pass with cached positions.
//

import SwiftUI

struct BackgroundView: View {
    @State private var orbOffsetTop: CGFloat = 0
    @State private var orbOffsetBottom: CGFloat = 0

    /// Optional tint color for shop / level auras.
    var tint: Color? = nil

    var body: some View {
        ZStack {
            GradientStyle.backgroundBase
                .ignoresSafeArea()

            GeometryReader { geo in
                ZStack {
                    StaticAura(tint: tint, size: geo.size)

                    DistantPlanet(size: geo.size)

                    DriftingOrbs(
                        orbOffsetTop: orbOffsetTop,
                        orbOffsetBottom: orbOffsetBottom,
                        size: geo.size
                    )
                }
            }
            .ignoresSafeArea()

            CachedStarField()
                .allowsHitTesting(false)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                orbOffsetTop = 40
            }
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                orbOffsetBottom = -30
            }
        }
    }
}

// MARK: - Static aura
private struct StaticAura: View {
    let tint: Color?
    let size: CGSize

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [Palette.green.opacity(0.20), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 360
            )

            RadialGradient(
                colors: [Palette.violet.opacity(0.18), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 380
            )

            if let tint = tint {
                RadialGradient(
                    colors: [tint.opacity(0.28), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 260
                )
            }
        }
    }
}

// MARK: - Drifting orbs
private struct DriftingOrbs: View {
    let orbOffsetTop: CGFloat
    let orbOffsetBottom: CGFloat
    let size: CGSize

    var body: some View {
        ZStack {
            Circle()
                .fill(Palette.cyan.opacity(0.22))
                .frame(width: 180, height: 180)
                .blur(radius: 60)
                .offset(
                    x: -80 + orbOffsetTop,
                    y: -size.height * 0.35 + orbOffsetTop
                )

            Circle()
                .fill(Palette.green.opacity(0.20))
                .frame(width: 220, height: 220)
                .blur(radius: 70)
                .offset(
                    x: size.width * 0.25 + orbOffsetBottom,
                    y: size.height * 0.3 - orbOffsetBottom
                )
        }
    }
}

// MARK: - Distant ringed planet (signature backdrop element)
private struct DistantPlanet: View {
    let size: CGSize

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Palette.violet.opacity(0.28), Palette.bg2.opacity(0.05), .clear],
                        center: UnitPoint(x: 0.4, y: 0.4),
                        startRadius: 2, endRadius: 95
                    )
                )
                .frame(width: 150, height: 150)

            Ellipse()
                .stroke(Palette.green.opacity(0.16), lineWidth: 5)
                .frame(width: 240, height: 74)
                .rotationEffect(.degrees(-20))

            Ellipse()
                .stroke(Palette.cyan.opacity(0.10), lineWidth: 2)
                .frame(width: 290, height: 92)
                .rotationEffect(.degrees(-20))
        }
        .blur(radius: 0.5)
        .offset(x: size.width * 0.30, y: -size.height * 0.32)
        .allowsHitTesting(false)
    }
}

// MARK: - Starfield
private struct CachedStarField: View {
    private static let stars: [Star] = {
        var gen = SystemRandomNumberGenerator()
        return (0..<54).map { _ in
            Star(
                x: CGFloat.random(in: 0...1, using: &gen),
                y: CGFloat.random(in: 0...1, using: &gen),
                radius: CGFloat.random(in: 0.6...1.6, using: &gen),
                color: [Palette.ink0, Palette.cyan, Palette.greenSoft]
                    .randomElement(using: &gen) ?? .white
            )
        }
    }()

    struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let radius: CGFloat
        let color: Color
    }

    var body: some View {
        Canvas(rendersAsynchronously: true) { ctx, size in
            for s in CachedStarField.stars {
                let d = s.radius * 2
                let rect = CGRect(
                    x: s.x * size.width - s.radius,
                    y: s.y * size.height - s.radius,
                    width: d,
                    height: d
                )
                ctx.fill(
                    Path(ellipseIn: rect),
                    with: .color(s.color.opacity(0.75))
                )
            }
        }
        .drawingGroup()
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}
