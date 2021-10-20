//
//  AuthCoordinator.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/16.
//

import Foundation
import UIKit

class AuthCoordinator: Coordinator {   

    var navigationController: UINavigationController?

    func eventOccured(with type: Event) {
        switch type {
        case .buttonDidTap:
            var cameraVC: UIViewController & Coordinating {
                let cameraVC = CameraViewController()
                cameraVC.coordinator = self
                return cameraVC
            }

            navigationController?.pushViewController(cameraVC, animated: true)
        }
    }

    func start() {
        var viewController: UIViewController & Coordinating {
            let viewController = LoginViewController()
            viewController.coordinator = self
            return viewController
        }

        navigationController?.setViewControllers([viewController], animated: false)
    }
}
