//
//  RecordsView.swift
//  PulsaMatchaSpace
//

import SwiftUI

struct RecordsView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @State private var user: User = StorageManager.shared.read()

    private var sectorsCleared: Int { max(0, user.levelProgress - 1) }
    private var totalStars: Int { user.levelStars.values.reduce(0, +) }
    private var maxStars: Int { LevelDefinition.all.count * 3 }
    private var skin: PulseSkin { PulseSkin.byId(user.equippedSkinId) }

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Spacer(minLength: 56)

                    statCard(
                        icon: "link",
                        tint: Palette.green,
                        title: "BEST CHAIN",
                        value: "\(user.bestChain)",
                        sub: "Longest survival sequence"
                    )

                    HStack(spacing: 16) {
                        miniCard(icon: "flag.checkered", tint: Palette.cyan,
                                 value: "\(sectorsCleared)/\(LevelDefinition.all.count)", title: "SECTORS")
                        miniCard(icon: "star.fill", tint: Palette.yellow,
                                 value: "\(totalStars)/\(maxStars)", title: "STARS")
                    }

                    HStack(spacing: 16) {
                        miniCard(icon: "sparkles", tint: Palette.green,
                                 value: "\(user.sparks)", title: "SPARKS")
                        miniCard(icon: "circle.hexagongrid.fill", tint: skin.color,
                                 value: skin.name, title: "PULSE")
                    }

                    Spacer(minLength: 40)
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
        .onAppear { user = StorageManager.shared.read() }
    }

    private var topBar: some View {
        ZStack {
            HStack(alignment: .top) {
                IconButton(systemName: "arrow.left") { coordinator.back() }
                Spacer()
            }
            HStack {
                Spacer()
                Text("Records")
                    .font(Fonts.display(28, .bold))
                    .foregroundColor(Palette.ink0)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Spacer()
            }
        }
        .frame(height: 44)
    }

    private func statCard(icon: String, tint: Color, title: String, value: String, sub: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(tint.opacity(0.14))
                Circle().stroke(tint.opacity(0.5), lineWidth: 1)
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(tint)
            }
            .frame(width: 60, height: 60)
            .softGlow(color: tint, radius: 16, opacity: 0.4)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Fonts.ui(11, .bold))
                    .tracking(1.6)
                    .foregroundColor(Palette.ink2)
                Text(value)
                    .font(Fonts.display(34, .heavy))
                    .foregroundColor(Palette.ink0)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(sub)
                    .font(Fonts.ui(12, .regular))
                    .foregroundColor(Palette.ink2)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg).fill(GradientStyle.card)
                RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.white.opacity(0.08), lineWidth: 1)
            }
        )
    }

    private func miniCard(icon: String, tint: Color, value: String, title: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(tint)
                .softGlow(color: tint, radius: 12, opacity: 0.4)
            Text(value)
                .font(Fonts.display(22, .bold))
                .foregroundColor(Palette.ink0)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(title)
                .font(Fonts.ui(11, .bold))
                .tracking(1.4)
                .foregroundColor(Palette.ink2)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg).fill(GradientStyle.card)
                RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.white.opacity(0.08), lineWidth: 1)
            }
        )
    }
}

#Preview {
    RecordsView()
        .environmentObject(Coordinator())
}
