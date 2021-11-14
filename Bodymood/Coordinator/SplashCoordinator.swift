import Foundation
import UIKit

class SplashCoordinator: Coordinator {

    var navigationController: UINavigationController?

    func eventOccured(with type: Event) {
        switch type {
        case .buttonDidTap:
            break
        }
    }

    func start() {
//        var viewController: UIViewController & Coordinating {
//            let viewController = SplashViewController()
//            viewController.coordinator = self
//            return viewController
//        }
//
//        navigationController?.setViewControllers([viewController], animated: false)
    }
}
