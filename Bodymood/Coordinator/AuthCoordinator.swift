import Foundation
import UIKit

class AuthCoordinator: Coordinator {

    var navigationController: UINavigationController?

    func eventOccured(with type: Event) {
        switch type {
        case .buttonDidTap:
            var cameraVC: UIViewController & Coordinating {
                let cameraVC = CameraViewController(viewModel: CameraViewModel())
                cameraVC.coordinator = self
                return cameraVC
            }
            navigationController?.pushViewController(cameraVC, animated: true)
        }
    }

    func start() {
        var viewController: UIViewController & Coordinating {
            let viewController = LoginViewController(viewModel: LoginViewModel(service: AuthService()))
            viewController.coordinator = self
            return viewController
        }

        navigationController?.setViewControllers([viewController], animated: false)
    }
}
