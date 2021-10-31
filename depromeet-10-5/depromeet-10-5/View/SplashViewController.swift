//
//  SplashViewController.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/24.
//

import UIKit
class SplashViewController: UIViewController, Coordinating {
    var coordinator: Coordinator?

    private lazy var imageView: UIImageView = { createSplashImageView() }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        style()
        layout()
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
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 31),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 41),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48)
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

    private func moveToPoster() {
        let mainVM = PosterListViewModel(useCase: AlbumUseCase())
        let mainVC = PosterListViewController(viewModel: mainVM)
        self.navigationController?.pushViewController(mainVC, animated: false)
    }

    private func moveToLogin() {
        let mainVM = AuthViewModel(service: AuthService())
        let mainVC = LoginViewController(viewModel: mainVM)
        self.navigationController?.pushViewController(mainVC, animated: false)
    }
}

extension SplashViewController {
    func createSplashImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_image")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        return imageView
    }
}
