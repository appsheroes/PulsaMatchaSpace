//
//  GameOverView.swift
//  PulsaMatchaSpace
//

import SwiftUI

struct GameOverView: View {
    @EnvironmentObject private var coordinator: Coordinator
    let score: Int
    let chain: Int
    let sparks: Int
    let mode: GameMode

    @State private var appeared = false

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 20) {
                Spacer()

                Text(headline)
                    .font(Fonts.display(28, .heavy))
                    .tracking(3)
                    .foregroundColor(Palette.magenta)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .shadow(color: Palette.magenta.opacity(0.8), radius: 14)
                    .scaleEffect(appeared ? 1 : 0.85)

                VStack(spacing: 10) {
                    Text(modeLabel)
                        .font(Fonts.ui(12, .bold))
                        .tracking(2)
                        .foregroundColor(Palette.ink2)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)

                    Text("\(chain)")
                        .font(Fonts.display(60, .heavy))
                        .monospacedDigit()
                        .foregroundColor(Palette.ink0)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .shadow(color: Palette.green.opacity(0.8), radius: 12)

                    Text("BEST CHAIN")
                        .font(Fonts.ui(11, .bold))
                        .tracking(2)
                        .foregroundColor(Palette.ink2)

                    Text("Score \(score)")
                        .font(Fonts.ui(13, .semibold))
                        .foregroundColor(Palette.ink1)
                        .padding(.top, 2)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: Radius.lg).fill(GradientStyle.card)
                        RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.white.opacity(0.08), lineWidth: 1)
                    }
                )
                .padding(.horizontal, Spacing.screenH)

                if sparks > 0 {
                    HStack(spacing: 8) {
                        SparkIcon(size: 22)
                        Text("+\(sparks) SPARKS")
                            .font(Fonts.display(18, .bold))
                            .tracking(1.5)
                            .foregroundColor(Palette.greenSoft)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 22)
                    .frame(height: 44)
                    .background(
                        ZStack {
                            Capsule().fill(Palette.green.opacity(0.1))
                            Capsule().stroke(Palette.green.opacity(0.35), lineWidth: 1)
                        }
                    )
                    .softGlow(color: Palette.green, radius: 18, opacity: 0.4)
                }

                Spacer()

                VStack(spacing: 10) {
                    PrimaryButton(title: "RETRY", icon: "arrow.clockwise") {
                        coordinator.path.removeAll {
                            if case .gameOver = $0 { return true }
                            if case .game = $0 { return true }
                            return false
                        }
                        coordinator.navigate(to: .game(mode))
                    }
                    GhostButton(title: "HOME") {
                        coordinator.popToHome()
                    }
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            Haptic.warning()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                appeared = true
            }
        }
    }

    private var headline: String {
        switch mode {
        case .survival: return "GAME OVER"
        case .level:    return "SECTOR FAILED"
        }
    }

    private var modeLabel: String {
        switch mode {
        case .survival: return "SURVIVAL RUN"
        case .level(let i): return "SECTOR \(i)"
        }
    }
}

#Preview {
    GameOverView(score: 240, chain: 12, sparks: 65, mode: .survival)
        .environmentObject(Coordinator())
}
