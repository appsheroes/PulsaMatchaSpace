//
//  LevelsView.swift
//  PulsaMatchaSpace
//

import SwiftUI

struct LevelsView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @State private var user: User = StorageManager.shared.read()

    private var levels: [LevelDefinition] { LevelDefinition.all }

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, Spacing.screenH)
                    .padding(.top, 8)

                header
                    .padding(.horizontal, Spacing.screenH)
                    .padding(.top, 12)

                progressBar
                    .padding(.horizontal, Spacing.screenH)
                    .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(levels) { level in
                            LevelNodeRow(
                                level: level,
                                user: user,
                                isCurrent: level.id == user.levelProgress,
                                action: { tap(level) }
                            )
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, Spacing.screenH)
                }
            }
        }
        .onAppear { user = StorageManager.shared.read() }
    }

    private var topBar: some View {
        HStack {
            IconButton(systemName: "arrow.left") { coordinator.back() }
            Spacer()
            Text("GALAXY 1")
                .font(Fonts.display(18, .bold))
                .tracking(2)
                .foregroundColor(Palette.ink0)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Spacer()
            SparksChip(amount: user.sparks)
        }
        .frame(height: 44)
    }

    private var header: some View {
        HStack {
            Text("Sequence Chain · \(earnedStars)/\(levels.count * 3) ★")
                .font(Fonts.ui(13, .bold))
                .tracking(1.2)
                .foregroundColor(Palette.ink2)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Spacer()
        }
    }

    private var progressBar: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.08))
                .frame(height: 8)
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [Palette.cyan, Palette.green],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .frame(width: progressWidth, height: 8)
                .softGlow(color: Palette.green, radius: 8, opacity: 0.5)
        }
    }

    private var progressWidth: CGFloat {
        let w = designCanvasWidth - Spacing.screenH * 2
        let ratio = CGFloat(user.levelProgress - 1) / CGFloat(levels.count)
        return max(0, min(1, ratio)) * w
    }

    private var earnedStars: Int { user.levelStars.values.reduce(0, +) }

    private func tap(_ level: LevelDefinition) {
        guard level.id <= user.levelProgress else {
            Haptic.warning()
            return
        }
        Haptic.medium()
        coordinator.navigate(to: .game(.level(level.id)))
    }
}

// MARK: - Level Node Row
struct LevelNodeRow: View {
    let level: LevelDefinition
    let user: User
    let isCurrent: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            if level.id % 2 == 0 { Spacer() }

            Button(action: action) { node }
                .disabled(level.id > user.levelProgress)

            if level.id % 2 == 1 { Spacer() }
        }
    }

    private var isUnlocked: Bool { level.id <= user.levelProgress }
    private var stars: Int { user.levelStars[level.id] ?? 0 }

    private var mainColor: Color {
        if !isUnlocked { return Color.white.opacity(0.15) }
        if level.isBoss { return Palette.magenta }
        if isCurrent { return Palette.green }
        return Palette.cyan
    }

    private var node: some View {
        VStack(spacing: 6) {
            if isCurrent {
                Text("NOW")
                    .font(Fonts.ui(10, .heavy))
                    .tracking(1.5)
                    .foregroundColor(Palette.bg0)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .frame(height: 18)
                    .background(Capsule().fill(Palette.green))
            }

            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(mainColor.opacity(isUnlocked ? 0.85 : 1))

                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1.5)

                VStack(spacing: 4) {
                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Palette.ink2)
                    } else if level.isBoss {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Palette.ink0)
                    } else {
                        Text("\(level.id)")
                            .font(Fonts.display(26, .bold))
                            .foregroundColor(Palette.ink0)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                    }

                    Text(level.isBoss ? "BOSS" : "SEC \(level.id)")
                        .font(Fonts.ui(9, .bold))
                        .tracking(1)
                        .foregroundColor(Palette.ink1)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
            }
            .frame(width: 100, height: 96)
            .softGlow(color: isUnlocked ? mainColor : .clear, radius: 18, opacity: isCurrent ? 0.7 : 0.3)

            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(i < stars ? Palette.yellow : Palette.ink3)
                        .softGlow(color: i < stars ? Palette.yellow : .clear, radius: 5, opacity: 0.7)
                }
            }
        }
    }
}

// MARK: - Level Complete View
struct LevelCompleteView: View {
    @EnvironmentObject private var coordinator: Coordinator
    let level: Int
    let stars: Int
    let sparks: Int
    @State private var appeared = false

    private var isLastLevel: Bool { level >= LevelDefinition.all.count }

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 24) {
                Spacer()

                Text("SECTOR \(level) CLEAR")
                    .font(Fonts.display(22, .bold))
                    .tracking(2)
                    .foregroundColor(Palette.green)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .shadow(color: Palette.green.opacity(0.7), radius: 10)

                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 40))
                            .foregroundColor(i < stars ? Palette.yellow : Color.white.opacity(0.12))
                            .softGlow(color: i < stars ? Palette.yellow : .clear, radius: 18, opacity: 0.7)
                            .scaleEffect(appeared ? 1 : 0.5)
                            .animation(.spring(response: 0.4, dampingFraction: 0.5).delay(Double(i) * 0.15), value: appeared)
                    }
                }

                HStack(spacing: 8) {
                    SparkIcon(size: 24)
                    Text("+\(sparks)")
                        .font(Fonts.display(24, .bold))
                        .foregroundColor(Palette.greenSoft)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }

                Spacer()

                VStack(spacing: 10) {
                    if !isLastLevel {
                        PrimaryButton(title: "NEXT SECTOR", icon: "play.fill") {
                            coordinator.path.removeAll { route in
                                if case .game = route { return true }
                                if case .levelComplete = route { return true }
                                return false
                            }
                            coordinator.navigate(to: .game(.level(level + 1)))
                        }
                    }
                    GhostButton(title: "BACK TO SECTORS") {
                        coordinator.path.removeAll { route in
                            if case .game = route { return true }
                            if case .levelComplete = route { return true }
                            return false
                        }
                    }
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            Haptic.success()
            withAnimation { appeared = true }
        }
    }
}

#Preview {
    LevelsView()
        .environmentObject(Coordinator())
}
