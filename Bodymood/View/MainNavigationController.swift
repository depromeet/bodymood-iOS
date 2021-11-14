import UIKit

class MainNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        topViewController
    }
}
