//
//  ShopView.swift
//  PulsaMatchaSpace
//
//  Cosmetic Pulse Skins — restyle the pop shockwave + field accent.
//  Unlocked with Sparks earned through play. No real-money purchases.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @State private var user: User = StorageManager.shared.read()
    @State private var index: Int = 0
    @State private var showInsufficient = false
    @State private var shortfall = 0
    @State private var bannerToken = 0

    private var skins: [PulseSkin] { PulseSkin.all }
    private var current: PulseSkin { skins[index] }

    var body: some View {
        ZStack {
            BackgroundView(tint: current.color)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                topBar
                    .padding(.top, 8)

                Spacer(minLength: 0)

                carousel

                dots

                Spacer(minLength: 0)

                infoCard
            }
            .padding()

            // Top banner shown when the player can't afford the skin.
            VStack {
                if showInsufficient {
                    insufficientBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }
            .padding(.top, 64)
            .padding(.horizontal, Spacing.screenH)
            .allowsHitTesting(false)
        }
        .onAppear {
            user = StorageManager.shared.read()
            if let idx = skins.firstIndex(where: { $0.id == user.equippedSkinId }) {
                index = idx
            }
        }
    }

    private var topBar: some View {
        HStack {
            IconButton(systemName: "arrow.left") { coordinator.back() }
            Spacer()
            Text("PULSE SHOP")
                .font(Fonts.display(18, .bold))
                .tracking(2)
                .foregroundColor(Palette.ink0)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Spacer()
            SparksChip(amount: user.sparks)
        }
    }

    // MARK: Carousel
    private var carousel: some View {
        GeometryReader { geo in
            ZStack {
                HStack {
                    IconButton(systemName: "chevron.left", size: 40) { prev() }
                        .padding(.leading, 4)
                    Spacer()
                    IconButton(systemName: "chevron.right", size: 40) { next() }
                        .padding(.trailing, 4)
                }

                PulseOrbView(color: current.color, size: 150)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(height: 300)
    }

    private var dots: some View {
        HStack(spacing: 6) {
            ForEach(skins.indices, id: \.self) { i in
                Circle()
                    .fill(i == index ? current.color : Color.white.opacity(0.25))
                    .frame(width: i == index ? 9 : 6, height: i == index ? 9 : 6)
                    .softGlow(color: i == index ? current.color : .clear, radius: 6, opacity: 0.5)
            }
        }
    }

    // MARK: Info card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(current.name)
                    .font(Fonts.display(22, .bold))
                    .foregroundColor(current.color)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Spacer()
                Text("\(index + 1) / \(skins.count)")
                    .font(Fonts.ui(13, .bold))
                    .tracking(1.2)
                    .foregroundColor(Palette.ink2)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }

            Text(current.desc)
                .font(Fonts.ui(14, .regular))
                .foregroundColor(Palette.ink1)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            HStack(spacing: 12) {
                statBar(title: "POWER", value: current.power, tint: current.color)
                statBar(title: "GLOW", value: current.glow, tint: current.color)
                statBar(title: "AURA", value: current.aura, tint: current.color)
            }

            actionButton
                .padding(.top)
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg).fill(GradientStyle.card)
                RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.white.opacity(0.08), lineWidth: 1)
            }
        )
        .shadow(color: .black.opacity(0.4), radius: 24, y: 8)
    }

    private func statBar(title: String, value: Int, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Fonts.ui(10, .bold))
                .tracking(1.2)
                .foregroundColor(Palette.ink2)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            HStack(spacing: 3) {
                ForEach(0..<4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < value ? tint : Color.white.opacity(0.1))
                        .frame(height: 5)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var actionButton: some View {
        let owned = user.ownedSkinIds.contains(current.id)
        let equipped = user.equippedSkinId == current.id
        if owned {
            if equipped {
                Text("EQUIPPED")
                    .font(Fonts.display(16, .bold))
                    .foregroundColor(Palette.bg0)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Capsule().fill(GradientStyle.primary))
                    .softGlow(color: Palette.green, radius: 16, opacity: 0.4)
            } else {
                PrimaryButton(title: "EQUIP") {
                    user.equippedSkinId = current.id
                    StorageManager.shared.write(user)
                }
            }
        } else {
            Button {
                purchase()
            } label: {
                HStack(spacing: 10) {
                    SparkIcon(size: 18)
                    Text("UNLOCK · \(current.price)")
                        .font(Fonts.display(16, .bold))
                        .foregroundColor(Palette.ink0)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Capsule().fill(GradientStyle.secondary))
                .softGlow(color: Palette.violet, radius: 18, opacity: 0.5)
            }
        }
    }

    // MARK: Insufficient-funds banner
    private var insufficientBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Palette.bg0)
            VStack(alignment: .leading, spacing: 1) {
                Text("NOT ENOUGH SPARKS")
                    .font(Fonts.display(14, .bold))
                    .tracking(0.5)
                    .foregroundColor(Palette.bg0)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("Need \(shortfall) more — earn Sparks by playing")
                    .font(Fonts.ui(11, .semibold))
                    .foregroundColor(Palette.bg0.opacity(0.8))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            Capsule().fill(
                LinearGradient(colors: [Palette.red, Palette.magenta],
                               startPoint: .leading, endPoint: .trailing)
            )
        )
        .softGlow(color: Palette.magenta, radius: 18, opacity: 0.6)
    }

    private func flashInsufficient() {
        Haptic.warning()
        shortfall = max(0, current.price - user.sparks)
        bannerToken += 1
        let token = bannerToken
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showInsufficient = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if token == bannerToken {
                withAnimation(.easeIn(duration: 0.25)) {
                    showInsufficient = false
                }
            }
        }
    }

    private func purchase() {
        guard user.sparks >= current.price else {
            flashInsufficient()
            return
        }
        Haptic.success()
        user.sparks -= current.price
        user.ownedSkinIds.insert(current.id)
        user.equippedSkinId = current.id
        StorageManager.shared.write(user)
    }

    private func next() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            index = (index + 1) % skins.count
        }
    }

    private func prev() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            index = (index - 1 + skins.count) % skins.count
        }
    }
}

#Preview {
    ShopView()
        .environmentObject(Coordinator())
}
