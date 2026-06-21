//
//  Models.swift
//  PulsaMatchaSpace
//
//  All models live here. `User` is the single persisted root.
//  Every field has a default so decoding is always lossless.
//

import SwiftUI

// MARK: - User
struct User: Codable {
    var hasSeenRules: Bool = false
    var sparks: Int = 200                  // soft currency earned by play
    var bestChain: Int = 0                 // best survival chain
    var levelProgress: Int = 1             // highest unlocked level (1-based)
    var levelStars: [Int: Int] = [:]       // level id -> 0...3 stars
    var ownedSkinIds: Set<String> = ["plasma"]
    var equippedSkinId: String = "plasma"
    var isVibrationOn: Bool = true
    // Reserved (no audio shipped) — kept for forward compatibility.
    var isSoundOn: Bool = true
    var isMusicOn: Bool = true
    var volume: Double = 0.72
}

// MARK: - Pulse Skin (cosmetic shop item)
/// Restyles the pop-pulse shockwave and the field accent. Purely cosmetic —
/// no gameplay advantage, all unlocked with in-game Sparks.
struct PulseSkin: Identifiable, Hashable {
    let id: String
    let name: String
    let desc: String
    let color: Color
    let price: Int
    let power: Int  // 1...4  (visual stat bars only)
    let glow: Int   // 1...4
    let aura: Int   // 1...4

    static let all: [PulseSkin] = [
        .init(id: "plasma",
              name: "Plasma Pulse",
              desc: "Classic matcha shock ring",
              color: Palette.green,
              price: 0,
              power: 2, glow: 3, aura: 2),
        .init(id: "solar",
              name: "Solar Flare",
              desc: "Golden burst on every pop",
              color: Palette.yellow,
              price: 250,
              power: 3, glow: 3, aura: 2),
        .init(id: "ion",
              name: "Ion Wave",
              desc: "Cyan ripple of pure energy",
              color: Palette.cyan,
              price: 400,
              power: 2, glow: 2, aura: 3),
        .init(id: "nova",
              name: "Nova",
              desc: "Magenta supernova shock",
              color: Palette.magenta,
              price: 650,
              power: 3, glow: 4, aura: 2),
        .init(id: "prism",
              name: "Prism",
              desc: "Violet crystalline pulse",
              color: Palette.violet,
              price: 900,
              power: 4, glow: 4, aura: 4)
    ]

    static func byId(_ id: String) -> PulseSkin {
        all.first(where: { $0.id == id }) ?? all[0]
    }
}

// MARK: - Level
/// A "Sector" in the Sequence Chain campaign. Clear it by tapping the
/// numbered balls in ascending order until `targetChain` correct grabs.
struct LevelDefinition: Identifiable, Hashable {
    let id: Int
    let name: String
    let targetChain: Int       // correct grabs needed to clear
    let sequenceLength: Int    // distinct numbers (1...K) shown on the field
    let ballCount: Int         // numbered balls drifting at once
    let baseSpeed: CGFloat     // drift speed (points/sec at reference cell)
    let hazardCount: Int       // void hazard orbs
    let grabTime: Double       // seconds allowed per grab
    let isBoss: Bool

    static let all: [LevelDefinition] = (1...12).map { i in
        let isBoss = (i % 6 == 0)
        let seqLen = min(4 + i / 2, 9)
        let balls = min(seqLen + 2 + i / 3, 14)
        let hazards = max(0, (i - 1) / 2)              // 0,0,1,1,2,2,3...
        let grab = max(1.9, 3.5 - Double(i) * 0.12)
        return LevelDefinition(
            id: i,
            name: "Sector \(i)",
            targetChain: 4 + i,                         // L1=5 ... L12=16
            sequenceLength: seqLen,
            ballCount: balls,
            baseSpeed: CGFloat(70 + i * 8),
            hazardCount: isBoss ? hazards + 1 : hazards,
            grabTime: grab,
            isBoss: isBoss
        )
    }
}
