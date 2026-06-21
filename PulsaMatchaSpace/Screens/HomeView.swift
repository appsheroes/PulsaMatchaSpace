//
//  HomeView.swift
//  PulsaMatchaSpace
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @State private var user: User = StorageManager.shared.read()
    @State private var floatY: CGFloat = 0
    @AppStorage("pms_hasSeenRules") private var hasSeenRules = false
    @State private var isRulesPresented = false

    private var skin: PulseSkin { PulseSkin.byId(user.equippedSkinId) }

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, Spacing.screenH)
                    .padding(.top, 8)

                Spacer(minLength: 0)

                logo
                    .padding(.top, 16)

                heroStage
                    .padding(.top, 8)

                Spacer(minLength: 0)

                bestChainChip
                    .padding(.bottom, 22)

                ctas
                    .padding(.horizontal, Spacing.screenH)
                    .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $isRulesPresented) {
            RulesView(isPresented: $isRulesPresented)
        }
        .onAppear {
            user = StorageManager.shared.read()
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                floatY = -12
            }
            if !hasSeenRules {
                isRulesPresented = true
            }
        }
    }

    // MARK: Top bar
    private var topBar: some View {
        HStack {
            SparksChip(amount: user.sparks)
            Spacer()
            IconButton(systemName: "gearshape.fill") {
                coordinator.navigate(to: .settings)
            }
        }
        .frame(height: 44)
    }

    // MARK: Logo
    private var logo: some View {
        VStack(spacing: 4) {
            Text("MATCHA")
                .font(Fonts.display(48, .heavy))
                .tracking(4)
                .foregroundStyle(GradientStyle.logoTitle())
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .shadow(color: Palette.green.opacity(0.55), radius: 12, x: 0, y: 2)

            Text("SPACE")
                .font(Fonts.display(15, .semibold))
                .tracking(6)
                .foregroundColor(Palette.green)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .shadow(color: Palette.green.opacity(0.7), radius: 8)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Hero
    private var heroStage: some View {
        ZStack {
            PulseOrbView(color: skin.color, size: 138)

            NumberBallView(number: 1, color: Palette.ballColor(1), size: 46)
                .offset(x: -100, y: -34 + floatY)
            NumberBallView(number: 2, color: Palette.ballColor(2), size: 40)
                .offset(x: 104, y: 6 - floatY)
            NumberBallView(number: 3, color: Palette.ballColor(3), size: 44)
                .offset(x: -64, y: 96 + floatY * 0.6)
        }
        .frame(height: 280)
    }

    private var bestChainChip: some View {
        Chip(
            text: "BEST CHAIN \(user.bestChain)",
            leading: AnyView(
                Image(systemName: "link")
                    .foregroundColor(Palette.green)
                    .font(.system(size: 12, weight: .bold))
            ),
            tint: Palette.ink0,
            bg: Color.white.opacity(0.08),
            border: Color.white.opacity(0.15),
            glowColor: Palette.green
        )
    }

    // MARK: CTAs
    private var ctas: some View {
        VStack(spacing: 14) {
            PrimaryButton(title: "PLAY", icon: "play.fill") {
                coordinator.navigate(to: .game(.survival))
            }

            HStack(spacing: 10) {
                SecondaryButton(title: "SECTORS") {
                    coordinator.navigate(to: .levels)
                }
                SecondaryButton(title: "SHOP") {
                    coordinator.navigate(to: .shop)
                }
            }

            HStack(spacing: 10) {
                GhostButton(title: "RECORDS") {
                    coordinator.navigate(to: .records)
                }
                GhostButton(title: "RULES") {
                    isRulesPresented = true
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(Coordinator())
}
