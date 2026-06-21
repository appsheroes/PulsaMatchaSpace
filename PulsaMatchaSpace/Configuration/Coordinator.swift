//
//  Coordinator.swift
//  PulsaMatchaSpace
//
//  Manual route stack + ZStack resolution. No NavigationStack / TabView.
//

import SwiftUI

enum GameMode: Equatable {
    case survival
    case level(Int)
}

enum Route: Equatable {
    case home
    case game(GameMode)
    case shop
    case levels
    case records
    case settings
    case gameOver(score: Int, chain: Int, sparks: Int, mode: GameMode)
    case levelComplete(level: Int, stars: Int, sparks: Int)
}

final class Coordinator: ObservableObject {
    @Published var path: [Route] = [.home]

    var current: Route { path.last ?? .home }

    func navigate(to route: Route) {
        withAnimation(.easeInOut(duration: 0.2)) {
            path.append(route)
        }
    }

    func back() {
        guard path.count > 1 else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            _ = path.popLast()
        }
    }

    func popToHome() {
        withAnimation(.easeInOut(duration: 0.2)) {
            path = [.home]
        }
    }

    @ViewBuilder
    func resolve(_ route: Route) -> some View {
        switch route {
        case .home:
            HomeView()
        case .game(let mode):
            GameView(mode: mode)
        case .shop:
            ShopView()
        case .levels:
            LevelsView()
        case .records:
            RecordsView()
        case .settings:
            SettingsView()
        case .gameOver(let score, let chain, let sparks, let mode):
            GameOverView(score: score, chain: chain, sparks: sparks, mode: mode)
        case .levelComplete(let level, let stars, let sparks):
            LevelCompleteView(level: level, stars: stars, sparks: sparks)
        }
    }
}
