//
//  PopView.swift
//  PulsaMatchaSpace
//
//  Lightweight modal presenter for in-game overlays (pause, confirmations).
//  Uses fullScreenCover with a transparent background so the SwiftUI engine
//  lifecycle is never disturbed the way `.sheet` would.
//

import SwiftUI

struct PopConfig {
    var backgroundColor: Color = Color.black.opacity(0.45)
}

extension View {
    @ViewBuilder
    func popView<Content: View>(
        config: PopConfig = .init(),
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            PopViewHelper(
                config: config,
                isPresented: isPresented,
                onDismiss: onDismiss,
                viewContent: content
            )
        )
    }
}

fileprivate struct PopViewHelper<ViewContent: View>: ViewModifier {
    var config: PopConfig
    @Binding var isPresented: Bool
    var onDismiss: () -> Void
    @ViewBuilder var viewContent: ViewContent

    @State private var present = false
    @State private var animateView = false

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $present, onDismiss: onDismiss) {
                ZStack {
                    Rectangle()
                        .fill(config.backgroundColor)
                        .ignoresSafeArea()
                        .opacity(animateView ? 1 : 0)
                        .onTapGesture {
                            isPresented = false
                        }

                    viewContent
                        .scaleEffect(animateView ? 1 : 0.85)
                        .opacity(animateView ? 1 : 0)
                        .onAppear {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                animateView = true
                            }
                        }
                }
                .background(BackgroundClearView())
            }
            .onChange(of: isPresented) { newValue in
                if newValue {
                    toggle(true)
                } else {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        animateView = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                        toggle(false)
                    }
                }
            }
    }

    private func toggle(_ status: Bool) {
        var t = Transaction()
        t.disablesAnimations = true
        withTransaction(t) {
            present = status
        }
    }
}

private struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        v.backgroundColor = .clear
        DispatchQueue.main.async {
            v.superview?.superview?.backgroundColor = .clear
        }
        return v
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
