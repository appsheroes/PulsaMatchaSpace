//
//  ScreenSize.swift
//  PulsaMatchaSpace
//

import SwiftUI

extension View {
    var screenWidth: CGFloat { UIScreen.main.bounds.width }
    var screenHeight: CGFloat { UIScreen.main.bounds.height }

    /// Fixed design canvas width: all UI dimensions assume a ~390-pt canvas.
    /// On iPad we cap content to this canvas so the layout stays consistent.
    var designCanvasWidth: CGFloat { min(UIScreen.main.bounds.width, 430) }
    var designCanvasHeight: CGFloat { UIScreen.main.bounds.height }
}
