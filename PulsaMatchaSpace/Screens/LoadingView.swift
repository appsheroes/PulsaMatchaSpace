//
//  LoadingView.swift
//  PulsaMatchaSpace
//
//  Branded splash. Every animated element loops continuously while shown;
//  flips `isLoading` false after ~3s. Not a coordinator route.
//

import SwiftUI

struct LoadingView: View {
    @Binding var isLoading: Bool

    @State private var startDate = Date()
    @State private var floatY: CGFloat = 0
    @EnvironmentObject var appFlyerHelper: AppDelegate
    
    private var skinColor: Color {
        PulseSkin.byId(StorageManager.shared.read().equippedSkinId).color
    }

    var body: some View {
        if appFlyerHelper.isShown {
            AppsFlyerNotificationView()
        } else {
            ZStack {
                BackgroundView()
                
                VStack(spacing: 0) {
                    Spacer().frame(height: 120)
                    
                    logo
                    
                    Spacer().frame(height: 8)
                    
                    heroStage
                    
                    Spacer()
                    
                    dotLoaderBlock
                        .padding(.bottom, 34)
                    
                    LoadingBar(startDate: startDate)
                        .frame(height: 6)
                        .padding()
                }
                .padding(.horizontal, Spacing.screenH)
            }
            .ignoresSafeArea()
            .onAppear {
                startDate = Date()
                withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                    floatY = -12
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isLoading = false
                    }
                }
            }
        }
    }

    private var logo: some View {
        VStack(spacing: 4) {
            Text("MATCHA")
                .font(Fonts.display(50, .heavy))
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

    private var heroStage: some View {
        ZStack {
            PulseOrbView(color: skinColor, size: 150)
                .offset(y: floatY)

            NumberBallView(number: 1, color: Palette.ballColor(1), size: 44)
                .offset(x: -104, y: -28 + floatY)
            NumberBallView(number: 2, color: Palette.ballColor(2), size: 38)
                .offset(x: 108, y: 18 - floatY)
            NumberBallView(number: 3, color: Palette.ballColor(3), size: 42)
                .offset(x: 70, y: -88 + floatY * 0.7)
        }
        .frame(height: 300)
    }

    private var dotLoaderBlock: some View {
        VStack(spacing: 10) {
            DotLoader()
            Text("LOADING")
                .font(Fonts.display(16, .semibold))
                .tracking(4)
                .foregroundColor(Palette.ink2)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
    }
}

// MARK: - Loading bar (bouncing segment)
private struct LoadingBar: View {
    let startDate: Date
    private let duration: Double = 2.2
    private let segmentRatio: CGFloat = 0.35

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08))

                TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { ctx in
                    let t = ctx.date.timeIntervalSince(startDate)
                    let raw = (t.truncatingRemainder(dividingBy: duration)) / duration
                    let phase = raw <= 0.5 ? raw * 2.0 : (1.0 - raw) * 2.0
                    let eased = CGFloat(0.5 - cos(phase * .pi) / 2.0)

                    let segW = w * segmentRatio
                    let travel = w - segW
                    let offset = travel * eased

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Palette.cyan, Palette.green],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, segW))
                        .shadow(color: Palette.green.opacity(0.7), radius: 12)
                        .shadow(color: Palette.cyan.opacity(0.5), radius: 24)
                        .offset(x: offset)
                }
            }
        }
        .clipShape(Capsule())
    }
}

fileprivate struct AppsFlyerNotificationView: View {
    @EnvironmentObject var appHelper: AppDelegate
    var body: some View {
        VStack{
            Spacer()
            Button(action: {
                appHelper.appsFlyerRulesView()
            }) {
                Text("RELOAD")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

// MARK: - Dot loader
private struct DotLoader: View {
    @State private var animate = false

    private let colors: [Color] = [
        Palette.green, Palette.cyan, Palette.violet, Palette.yellow, Palette.green
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(colors.indices, id: \.self) { i in
                Circle()
                    .fill(colors[i])
                    .frame(width: 8, height: 8)
                    .softGlow(color: colors[i], radius: 8, opacity: 0.85)
                    .scaleEffect(animate ? 1.2 : 0.6)
                    .opacity(animate ? 1.0 : 0.4)
                    .animation(
                        .easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.15),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

#Preview {
    LoadingView(isLoading: .constant(true))
}
