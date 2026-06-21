//
//  SettingsView.swift
//  PulsaMatchaSpace
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @State private var user: User = StorageManager.shared.read()
    @State private var showPrivacy = false
    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Spacer(minLength: 50)

                    section(title: "GAMEPLAY") {
                        toggleRow(
                            title: "Vibration",
                            icon: "iphone.radiowaves.left.and.right",
                            tint: Palette.magenta,
                            isOn: bind(\.isVibrationOn)
                        )
                        separator
                        actionRow(
                            title: "Privacy Policy",
                            icon: "lock.fill",
                            tint: Palette.cyan
                        ) {
                            showPrivacy = true
                        }
                    }

                    section(title: "DATA") {
                        destructiveRow(
                            title: "Delete Data",
                            icon: "trash.fill",
                            tint: Palette.magenta
                        ) {
                            showDeleteConfirm = true
                        }
                    }

                    Text("Version 1.0.0")
                        .font(Fonts.ui(11, .semibold))
                        .foregroundColor(Palette.ink3)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .padding(.top, 8)

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
        .popView(isPresented: $showPrivacy) {
            PrivacyPolicyOverlay(onClose: { showPrivacy = false })
        }
        .popView(isPresented: $showDeleteConfirm) {
            DeleteDataOverlay(
                onCancel: { showDeleteConfirm = false },
                onDelete: {
                    showDeleteConfirm = false
                    Haptic.warning()
                    StorageManager.shared.reset()
                    user = StorageManager.shared.read()
                    coordinator.popToHome()
                }
            )
        }
    }

    private var topBar: some View {
        ZStack {
            HStack(alignment: .top) {
                IconButton(systemName: "arrow.left") { coordinator.back() }
                Spacer()
            }
            HStack {
                Spacer()
                Text("Settings")
                    .font(Fonts.display(28, .bold))
                    .foregroundColor(Palette.ink0)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Spacer()
            }
        }
        .frame(height: 44)
    }

    private var separator: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(height: 1)
            .padding(.leading, 58)
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Fonts.ui(11, .bold))
                .tracking(2)
                .foregroundColor(Palette.ink3)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(.horizontal, 8)

            VStack(spacing: 0) {
                content()
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.lg).fill(GradientStyle.card)
                    RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.white.opacity(0.08), lineWidth: 1)
                }
            )
        }
    }

    private func toggleRow(title: String, icon: String, tint: Color, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            iconWell(icon: icon, tint: tint)
            Text(title)
                .font(Fonts.ui(15, .semibold))
                .foregroundColor(Palette.ink0)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Spacer()
            NeonToggle(isOn: isOn, tint: tint)
        }
        .padding(.horizontal, 14)
        .frame(height: 56)
    }

    private func actionRow(title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                iconWell(icon: icon, tint: tint)
                Text(title)
                    .font(Fonts.ui(15, .semibold))
                    .foregroundColor(Palette.ink0)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Palette.ink3)
            }
            .padding(.horizontal, 14)
            .frame(height: 56)
        }
    }

    private func destructiveRow(title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                iconWell(icon: icon, tint: tint)
                Text(title)
                    .font(Fonts.ui(15, .semibold))
                    .foregroundColor(Palette.ink0)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Palette.ink3)
            }
            .padding(.horizontal, 14)
            .frame(height: 56)
        }
    }

    private func iconWell(icon: String, tint: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.3), tint.opacity(0.12)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            RoundedRectangle(cornerRadius: 10)
                .stroke(tint.opacity(0.6), lineWidth: 1)
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(tint)
        }
        .frame(width: 32, height: 32)
    }

    private func bind(_ keyPath: WritableKeyPath<User, Bool>) -> Binding<Bool> {
        Binding(
            get: { self.user[keyPath: keyPath] },
            set: { newValue in
                self.user[keyPath: keyPath] = newValue
                StorageManager.shared.write(self.user)
            }
        )
    }
}

// MARK: - Overlays
private struct PrivacyPolicyOverlay: View {
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("PRIVACY POLICY")
                    .font(Fonts.display(20, .bold))
                    .tracking(2)
                    .foregroundColor(Palette.ink0)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Spacer()
                IconButton(systemName: "xmark") { onClose() }
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    policyParagraph("Matcha Space does not collect, store, or share any personal information.")
                    policyParagraph("Your progress, sparks, and unlocked pulse skins are stored locally on your device using iOS preferences. You can erase everything anytime with Delete Data in Settings.")
                    policyParagraph("The game uses no accounts, no analytics, no trackers, no advertising identifiers, and no third‑party services.")
                    policyParagraph("Because nothing leaves your device, there is nothing for us to access or recover after deletion.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            PrimaryButton(title: "CLOSE", icon: "checkmark", action: onClose)
        }
        .padding(22)
        .frame(width: 330)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg).fill(GradientStyle.card)
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            }
        )
        .softGlow(color: Palette.cyan, radius: 26, opacity: 0.35)
    }

    private func policyParagraph(_ text: String) -> some View {
        Text(text)
            .font(Fonts.ui(14, .regular))
            .foregroundColor(Palette.ink1)
            .minimumScaleFactor(0.6)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct DeleteDataOverlay: View {
    let onCancel: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("DELETE DATA?")
                .font(Fonts.display(22, .bold))
                .tracking(2)
                .foregroundColor(Palette.ink0)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text("This resets your chain records, sparks, sectors, and unlocked pulse skins on this device.")
                .font(Fonts.ui(14, .regular))
                .foregroundColor(Palette.ink1)
                .minimumScaleFactor(0.6)
                .multilineTextAlignment(.center)

            HStack(spacing: 10) {
                GhostButton(title: "CANCEL", action: onCancel)
                Button(action: onDelete) {
                    Text("DELETE")
                        .font(Fonts.display(16, .bold))
                        .foregroundColor(Palette.bg0)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Capsule().fill(LinearGradient(colors: [Palette.magenta, Palette.violetDeep], startPoint: .top, endPoint: .bottom)))
                        .softGlow(color: Palette.magenta, radius: 18, opacity: 0.55)
                }
            }
        }
        .padding(22)
        .frame(width: 330)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg).fill(GradientStyle.card)
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            }
        )
        .softGlow(color: Palette.magenta, radius: 26, opacity: 0.35)
    }
}

#Preview {
    SettingsView()
        .environmentObject(Coordinator())
}
