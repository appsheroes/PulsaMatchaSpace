//
//  CompasView.swift
//  Relia
//
//  Created by Anatoly Lapshin on 06.11.2025.
//

import Foundation
import SafariServices

final class AppsFlyersHelperScreenModificator {
    func configureScreen(controller: SFSafariViewController, parrentView: UIView){
        var topOffset: CGFloat = 0
        var bottomOffset: CGFloat = 0
        var viewTopConstraint: NSLayoutConstraint?
        var viewBottomConstraint: NSLayoutConstraint?
        var hasNotch: Bool {
            let window = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            return bottomPadding > 20
        }
        if #unavailable(iOS 26.0) {
            if UIDevice.current.orientation.isLandscape {
                topOffset = -43
                bottomOffset = 0
            } else {
                if hasNotch {
                    topOffset = -100
                    bottomOffset = 90
                } else {
                    topOffset = -44
                    bottomOffset = 44
                }
            }
        }
        viewTopConstraint?.isActive = false
        viewBottomConstraint?.isActive = false
        if let safariView = controller.view {
            if #available(iOS 26.0, *) {
                viewTopConstraint = safariView.topAnchor.constraint(equalTo: parrentView.topAnchor, constant: topOffset)
                viewBottomConstraint = safariView.bottomAnchor.constraint(equalTo: parrentView.bottomAnchor, constant: bottomOffset)
            } else {
                viewTopConstraint = safariView.topAnchor.constraint(equalTo: parrentView.safeAreaLayoutGuide.topAnchor, constant: topOffset)
                viewBottomConstraint = safariView.bottomAnchor.constraint(equalTo: parrentView.safeAreaLayoutGuide.bottomAnchor, constant: bottomOffset)
            }
            viewTopConstraint?.isActive = true
            viewBottomConstraint?.isActive = true
        }
        parrentView.layoutIfNeeded()
    }
}
