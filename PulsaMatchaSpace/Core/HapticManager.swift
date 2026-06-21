//
//  HapticManager.swift
//  PulsaMatchaSpace
//

import UIKit
import SwiftUI

enum Haptic {
    private static var isEnabled: Bool {
        StorageManager.shared.read().isVibrationOn
    }

    static func light() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func rigid() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func success() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func error() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
