//
//  GameView.swift
//  PulsaMatchaSpace
//
//  The Sequence Chain arena. The game loop runs on a CADisplayLink inside
//  GameEngine; only discrete events publish. Per-frame rendering (ball /
//  hazard positions, pop shockwaves, the grab timer) is driven by
//  TimelineView(.animation) so only the field repaints each frame.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var engine: GameEngine
    @State private var showPause = false
    let mode: GameMode

    private let skin: PulseSkin

    init(mode: GameMode) {
        self.mode = mode
        self.skin = PulseSkin.byId(StorageManager.shared.read().equippedSkinId)
        _engine = StateObject(wrappedValue: GameEngine(mode: mode))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                BackgroundView()

                VStack(spacing: 12) {
                    TopHUD(engine: engine, skinColor: skin.color) {
                        engine.pause(true)
                        showPause = true
                    }
                    SubHUD(engine: engine, mode: mode)
                    FieldContainer(engine: engine, skin: skin)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, 8)
                .padding(.bottom, 10)

                FlashOverlay(engine: engine)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: engine.isFinished) { finished in
            guard finished else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                handleFinish()
            }
        }
        .onChange(of: scenePhase) { phase in
            // Backgrounding pauses the run and surfaces the pause overlay so
            // the player resumes deliberately rather than to a frozen field.
            if phase != .active, engine.isRunning, !engine.isFinished, !showPause {
                engine.pause(true)
                showPause = true
            }
        }
        .popView(isPresented: $showPause) {
            PauseOverlay(
                onResume: {
                    showPause = false
                    engine.pause(false)
                },
                onExit: {
                    showPause = false
                    engine.stop()
                    coordinator.popToHome()
                }
            )
        }
    }

    private func handleFinish() {
        var u = StorageManager.shared.read()
        switch mode {
        case .survival:
            u.bestChain = max(u.bestChain, engine.bestChainRun)
            let sparks = engine.bestChainRun * 5 + engine.score / 20
            u.sparks += sparks
            StorageManager.shared.write(u)
            coordinator.navigate(to: .gameOver(score: engine.score, chain: engine.bestChainRun, sparks: sparks, mode: mode))

        case .level(let i):
            if engine.didWin {
                let stars = min(3, max(1, engine.lives))
                u.levelStars[i] = max(u.levelStars[i] ?? 0, stars)
                u.levelProgress = max(u.levelProgress, i + 1)
                let sparks = 40 + stars * 40 + engine.bestChainRun * 2
                u.sparks += sparks
                StorageManager.shared.write(u)
                coordinator.navigate(to: .levelComplete(level: i, stars: stars, sparks: sparks))
            } else {
                let sparks = engine.bestChainRun
                u.sparks += sparks
                StorageManager.shared.write(u)
                coordinator.navigate(to: .gameOver(score: engine.score, chain: engine.bestChainRun, sparks: sparks, mode: mode))
            }
        }
    }
}

// MARK: - Top HUD
private struct TopHUD: View {
    @ObservedObject var engine: GameEngine
    let skinColor: Color
    let onPause: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            IconButton(systemName: "pause.fill", action: onPause)
            Spacer()
            TargetPill(number: engine.nextNumber, color: skinColor)
            Spacer()
            LivesStrip(lives: engine.lives)
        }
        .frame(height: 56)
    }
}

private struct TargetPill: View {
    let number: Int
    let color: Color
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 0) {
                Text("TAP")
                    .font(Fonts.ui(10, .bold))
                    .tracking(2)
                    .foregroundColor(Palette.ink2)
                Text("NEXT")
                    .font(Fonts.ui(10, .bold))
                    .tracking(2)
                    .foregroundColor(Palette.ink2)
            }
            Text("\(number)")
                .font(Fonts.display(34, .heavy))
                .foregroundColor(.white)
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .shadow(color: color.opacity(0.9), radius: 8)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
        .background(
            ZStack {
                Capsule().fill(GradientStyle.timerPill)
                Capsule().stroke(color.opacity(0.6), lineWidth: 1.5)
            }
        )
        .softGlow(color: color, radius: 20, opacity: 0.45)
        .scaleEffect(pulse ? 1.04 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

private struct LivesStrip: View {
    let lives: Int
    var body: some View {
        HStack(spacing: 4) {
            HeartIcon(isActive: lives >= 1)
            HeartIcon(isActive: lives >= 2)
            HeartIcon(isActive: lives >= 3)
        }
    }
}

// MARK: - Sub HUD (chain + objective + grab timer)
private struct SubHUD: View {
    @ObservedObject var engine: GameEngine
    let mode: GameMode

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Chip(
                    text: "CHAIN \(engine.chain)",
                    leading: AnyView(
                        Image(systemName: "link")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Palette.green)
                    ),
                    tint: Palette.greenSoft,
                    bg: Palette.green.opacity(0.08),
                    border: Palette.green.opacity(0.3),
                    glowColor: Palette.green
                )

                Spacer()

                Chip(
                    text: objectiveText,
                    tint: Palette.cyan,
                    bg: Palette.cyan.opacity(0.08),
                    border: Palette.cyan.opacity(0.3),
                    glowColor: Palette.cyan
                )
            }
            .frame(height: 34)

            GrabTimerBar(engine: engine)
                .frame(height: 8)
        }
    }

    private var objectiveText: String {
        switch mode {
        case .survival:
            return "SURVIVE"
        case .level:
            if let t = engine.targetChain { return "GOAL \(engine.chain)/\(t)" }
            return "SURVIVE"
        }
    }
}

/// Depleting "pulse window" bar. Reads the engine's non-@Published
/// grabFraction inside a TimelineView so only this bar repaints.
private struct GrabTimerBar: View {
    let engine: GameEngine

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { _ in
                let frac = engine.grabFraction
                let color = barColor(frac)
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(color)
                        .frame(width: max(0, w * CGFloat(frac)))
                        .softGlow(color: color, radius: 8, opacity: 0.6)
                }
            }
        }
    }

    private func barColor(_ frac: Double) -> Color {
        if frac < 0.25 { return Palette.red }
        if frac < 0.5 { return Palette.yellow }
        return Palette.green
    }
}

// MARK: - Field container
private struct FieldContainer: View {
    @ObservedObject var engine: GameEngine
    let skin: PulseSkin

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let edge = min(size.width, size.height * 0.98)
            let fieldSize = CGSize(width: edge, height: edge)

            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(GradientStyle.fieldFill)
                    .frame(width: fieldSize.width, height: fieldSize.height)

                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(skin.color.opacity(0.35), lineWidth: 1.5)
                    .frame(width: fieldSize.width, height: fieldSize.height)

                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(skin.color.opacity(0.15), lineWidth: 12)
                    .blur(radius: 14)
                    .frame(width: fieldSize.width, height: fieldSize.height)
                    .drawingGroup()

                FieldBoard(engine: engine, fieldSize: fieldSize, skinColor: skin.color)
                    .frame(width: fieldSize.width, height: fieldSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .frame(width: size.width, height: size.height, alignment: .center)
            .onAppear { engine.start(fieldSize: fieldSize) }
            .onDisappear { engine.stop() }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Field board (static grid + dynamic gameplay layer + tap input)
private struct FieldBoard: View {
    @ObservedObject var engine: GameEngine
    let fieldSize: CGSize
    let skinColor: Color

    var body: some View {
        ZStack {
            FieldRadarGrid(fieldSize: fieldSize)

            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { context in
                let date = context.date
                let now = CACurrentMediaTime()
                let pulse = CGFloat((sin(date.timeIntervalSinceReferenceDate * 4.0) + 1) / 2)
                let spin = date.timeIntervalSinceReferenceDate * 55.0

                let balls = engine.balls
                let hazards = engine.hazards
                let pops = engine.pops
                let target = engine.nextNumber

                ZStack {
                    ForEach(hazards) { h in
                        VoidOrbView(size: h.radius * 2, spin: spin)
                            .position(h.position)
                    }

                    ForEach(balls) { b in
                        NumberBallView(
                            number: b.number,
                            color: Palette.ballColor(b.number),
                            size: b.radius * 2,
                            isTarget: b.number == target,
                            pulse: pulse
                        )
                        .position(b.position)
                    }

                    ForEach(pops) { p in
                        PopRingView(
                            color: p.color,
                            progress: min(1, (now - p.birth) / 0.55),
                            size: 64
                        )
                        .position(p.position)
                    }
                }
            }
        }
        .frame(width: fieldSize.width, height: fieldSize.height)
        .contentShape(Rectangle())
        .gesture(
            SpatialTapGesture()
                .onEnded { value in
                    engine.handleTap(at: value.location)
                }
        )
    }
}

/// Faint static "radar" grid — concentric pulse rings + crosshair, baked once
/// into a Metal texture. Reinforces the pulse / space-sonar identity.
private struct FieldRadarGrid: View {
    let fieldSize: CGSize

    var body: some View {
        Canvas { ctx, size in
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            let maxR = min(size.width, size.height) * 0.52
            let ringShade = GraphicsContext.Shading.color(Palette.cyan.opacity(0.10))
            let rings = 5
            for i in 1...rings {
                let r = maxR * CGFloat(i) / CGFloat(rings)
                let rect = CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)
                ctx.stroke(Path(ellipseIn: rect), with: ringShade, lineWidth: 1)
            }
            var cross = Path()
            cross.move(to: CGPoint(x: c.x, y: 0))
            cross.addLine(to: CGPoint(x: c.x, y: size.height))
            cross.move(to: CGPoint(x: 0, y: c.y))
            cross.addLine(to: CGPoint(x: size.width, y: c.y))
            ctx.stroke(cross, with: GraphicsContext.Shading.color(Palette.green.opacity(0.07)), lineWidth: 1)
        }
        .drawingGroup()
        .allowsHitTesting(false)
    }
}

// MARK: - Flash overlay (wrong / hazard / timeout feedback)
private struct FlashOverlay: View {
    @ObservedObject var engine: GameEngine

    var body: some View {
        Group {
            if let flash = engine.flash {
                Rectangle()
                    .fill(flash.color.opacity(0.18))
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - Pause overlay
struct PauseOverlay: View {
    let onResume: () -> Void
    let onExit: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("PAUSED")
                .font(Fonts.display(28, .bold))
                .tracking(3)
                .foregroundColor(Palette.ink0)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .shadow(color: Palette.green.opacity(0.8), radius: 12)

            PrimaryButton(title: "RESUME", icon: "play.fill", action: onResume)
            GhostButton(title: "EXIT TO HOME", action: onExit)
        }
        .padding(28)
        .frame(width: 300)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg).fill(GradientStyle.card)
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            }
        )
        .softGlow(color: Palette.green, radius: 30, opacity: 0.3)
    }
}

#Preview {
    GameView(mode: .survival)
        .environmentObject(Coordinator())
}
