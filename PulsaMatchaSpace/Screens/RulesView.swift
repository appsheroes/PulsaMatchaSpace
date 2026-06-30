//
//  RulesView.swift
//  PulsaMatchaSpace
//

import SwiftUI

struct RulesView: View {
    @Binding var isPresented: Bool
    @AppStorage("pms_hasSeenRules") private var hasSeenRules = false

    private let rules: [RuleItem] = [
        .init(
            icon: "target",
            tint: Palette.green,
            title: "Hit the Target",
            text: "Each round a random target number lights up. Tap a drifting ball showing that number to pop it and grow your chain — then a new random target appears."
        ),
        .init(
            icon: "scope",
            tint: Palette.cyan,
            title: "Follow the Glow",
            text: "The number you need next is shown in the TAP NEXT pill and the matching balls glow with a pulsing ring. Pop the right one."
        ),
        .init(
            icon: "xmark.octagon.fill",
            tint: Palette.red,
            title: "Wrong Number",
            text: "Tap the wrong number and your chain breaks back to the start and you lose a life. Look before you tap."
        ),
        .init(
            icon: "timer",
            tint: Palette.yellow,
            title: "Pulse Timer",
            text: "The bar below the chain drains between grabs. Pop the next number before it empties or you lose a life."
        ),
        .init(
            icon: "circle.dotted",
            tint: Palette.magenta,
            title: "Void Orbs",
            text: "Dark void orbs roam the field — and more keep appearing the further you get. Never tap one: it costs a life and scatters the balls into chaos."
        ),
        .init(
            icon: "flag.checkered",
            tint: Palette.ink0,
            title: "Sectors & Stars",
            text: "Clear a sector by reaching its target chain. The more lives you finish with, the more stars you earn."
        )
    ]

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Spacer(minLength: 58)

                    headerCard

                    VStack(spacing: 12) {
                        ForEach(rules) { rule in
                            RuleRow(rule: rule)
                        }
                    }

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, 20)
            }

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, Spacing.screenH)
                    .padding(.top, 8)
                Spacer()
            }
        }
        .onAppear {
            hasSeenRules = true
        }
    }

    private var topBar: some View {
        ZStack {
            HStack(alignment: .top) {
                IconButton(systemName: "arrow.left") {
                    hasSeenRules = true
                    isPresented = false
                }
                Spacer()
            }
            HStack {
                Spacer()
                Text("How to Play")
                    .font(Fonts.display(26, .bold))
                    .foregroundColor(Palette.ink0)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Spacer()
            }
        }
        .frame(height: 44)
    }

    private var headerCard: some View {
        VStack(spacing: 10) {
            Text("MATCHA SPACE")
                .font(Fonts.display(24, .heavy))
                .tracking(1)
                .foregroundStyle(GradientStyle.logoTitle())
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text("Pop the ball that matches the target number, beat the pulse timer, and dodge the void.")
                .font(Fonts.ui(15, .semibold))
                .foregroundColor(Palette.ink1)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg).fill(GradientStyle.card)
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(Palette.green.opacity(0.35), lineWidth: 1.5)
            }
        )
        .softGlow(color: Palette.green, radius: 24, opacity: 0.25)
    }
}

private struct RuleItem: Identifiable {
    let id = UUID()
    let icon: String
    let tint: Color
    let title: String
    let text: String
}

private struct RuleRow: View {
    let rule: RuleItem

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: rule.icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(rule.tint)
                .frame(width: 42, height: 42)
                .background(
                    ZStack {
                        Circle().fill(rule.tint.opacity(0.12))
                        Circle().stroke(rule.tint.opacity(0.35), lineWidth: 1)
                    }
                )
                .softGlow(color: rule.tint, radius: 12, opacity: 0.28)

            VStack(alignment: .leading, spacing: 5) {
                Text(rule.title)
                    .font(Fonts.display(17, .bold))
                    .foregroundColor(Palette.ink0)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text(rule.text)
                    .font(Fonts.ui(14, .semibold))
                    .foregroundColor(Palette.ink1)
                    .minimumScaleFactor(0.6)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Radius.md).fill(Color.white.opacity(0.07))
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(Color.white.opacity(0.11), lineWidth: 1)
            }
        )
    }
}

#Preview {
    RulesView(isPresented: .constant(true))
}
