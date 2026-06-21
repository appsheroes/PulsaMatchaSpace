//
//  ContentView.swift
//  PulsaMatchaSpace
//
//  Root view + coordinator host. LoadingView is NOT a route — it is gated
//  here by a simple @State flag and flips itself off after the splash.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator = Coordinator()
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if isLoading {
                LoadingView(isLoading: $isLoading)
                    .transition(.opacity)
            } else {
                coordinator.resolve(coordinator.current)
                    .id(routeID(coordinator.current))
                    .transition(.opacity)
            }
        }
        .environmentObject(coordinator)
    }

    private func routeID(_ r: Route) -> String {
        switch r {
        case .home: return "home"
        case .game(let m):
            switch m {
            case .survival: return "game-survival"
            case .level(let i): return "game-level-\(i)"
            }
        case .shop: return "shop"
        case .levels: return "levels"
        case .records: return "records"
        case .settings: return "settings"
        case .gameOver: return "gameOver"
        case .levelComplete(let l, _, _): return "levelComplete-\(l)"
        }
    }
}

#Preview {
    ContentView()
}
