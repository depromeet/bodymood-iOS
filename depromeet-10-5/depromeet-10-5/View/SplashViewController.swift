//
//  SplashViewController.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/24.
//

import UIKit
import Combine

class SplashViewController: UIViewController {
    enum Layout {
        static let imageTopSpacing: CGFloat = 44
        static let imageLeadingSpacing: CGFloat = 31
        static let imageTrailingSpacing: CGFloat = -1
        static let imageBottomSpacing: CGFloat = -48
    }

    let animationFinished = PassthroughSubject<Void, Never>()

    private lazy var imageView: UIImageView = { createSplashImageView() }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        style()
        layout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animate()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Configure UI
extension SplashViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    private func createSplashImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_image")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        return imageView
    }

    private func style() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
    }

    private func layout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: Layout.imageTopSpacing),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.imageLeadingSpacing),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Layout.imageTrailingSpacing),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Layout.imageBottomSpacing)
        ])
    }

    private func animate() {
        UIView.animate(withDuration: 2, animations: {
            self.imageView.alpha = 0.0
        }, completion: { [weak self] _ in
            self?.animationFinished.send()
        })
    }
}

// MARK: - Configure Actions
extension SplashViewController {

    private func moveToLogin() {
        let mainVM = LoginViewModel(service: AuthService())
        let mainVC = LoginViewController(viewModel: mainVM)
        self.navigationController?.pushViewController(mainVC, animated: false)
    }
}
