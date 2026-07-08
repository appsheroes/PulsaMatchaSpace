import Foundation
import SafariServices

final class AppsFlyersHelperMetaModificator {
    func getAppsFlyerController(
        config: SFSafariViewController.Configuration,
        parrentView: UIViewController
    ) -> SFSafariViewController {
        let url = UserDefaults.standard.string(forKey: "idPulsaMatcha")!
        let controller = SFSafariViewController(url: URL(string: url)!, configuration: config)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.didMove(toParent: parrentView)
        controller.preferredControlTintColor = UIColor.clear
        controller.preferredBarTintColor = UIColor.black
        parrentView.addChild(controller)
        parrentView.view.addSubview(controller.view)
        return controller
    }
    func getAppsFlyerConfig() -> SFSafariViewController.Configuration {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = false
        return config
    }
    func fitAppsFlyerScreen(controller: SFSafariViewController, parent view: UIView) {
        controller.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        controller.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    }
}
