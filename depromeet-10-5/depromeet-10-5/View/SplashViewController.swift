//
//  SplashViewController.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/24.
//

import UIKit
class SplashViewController: UIViewController, Coordinating {
    enum Layout {
        static let imageTopSpacing: CGFloat = 44
        static let imageLeadingSpacing: CGFloat = 31
        static let imageTrailingSpacing: CGFloat = -1
        static let imageBottomSpacing: CGFloat = -48
    }

    var coordinator: Coordinator?

    private lazy var imageView: UIImageView = { createSplashImageView() }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        style()
        layout()
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.animate()
        }
    }

    private func style() {
        view.backgroundColor = .white

        navigationController?.navigationBar.backgroundColor = .black
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
        UIView.animate(withDuration: 1.5, delay: 0.3, options: .curveEaseOut, animations: {
            self.imageView.alpha = 0.0

        }, completion: { done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if UserDefaults.standard.string(forKey: UserDefaultKey.accessToken) != "" {
                        self.moveToPoster()
                    } else {
                        self.moveToLogin()
                    }
                }
            }
        })
    }
}

// MARK: - Configure Actions
extension SplashViewController {
    private func moveToPoster() {
        let mainVM = PosterListViewModel(useCase: PosterUseCase())
        let mainVC = PosterListViewController(viewModel: mainVM)
        let nav = MainNavigationController(rootViewController: mainVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: false, completion: nil)
    }

    private func moveToLogin() {
        let mainVM = LoginViewModel(service: AuthService())
        let mainVC = LoginViewController(viewModel: mainVM)
        self.navigationController?.pushViewController(mainVC, animated: false)
    }
}
