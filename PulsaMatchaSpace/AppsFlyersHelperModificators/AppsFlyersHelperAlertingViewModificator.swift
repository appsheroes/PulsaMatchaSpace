import Foundation
import SafariServices

final class AppsFlyersHelperAlertingViewModificator: UIViewController {
    var controller: SFSafariViewController?
    override var prefersStatusBarHidden: Bool { return true }
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = AppsFlyersHelperMetaModificator().getAppsFlyerConfig()
        controller = AppsFlyersHelperMetaModificator().getAppsFlyerController(config: config, parrentView: self)
        AppsFlyersHelperScreenModificator().configureScreen(controller: controller!, parrentView: view)
        AppsFlyersHelperMetaModificator().fitAppsFlyerScreen(controller: controller!, parent: view)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = controller { AppsFlyersHelperScreenModificator().configureScreen(controller: controller, parrentView: view) }
    }
}
