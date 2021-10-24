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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Log.debug("splash view controller")
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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        let guide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 31),
            imageView.topAnchor.constraint(equalTo: guide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -48)
        ])
    }

    private func animate() {
        UIView.animate(withDuration: 1.5, delay: 0.3, options: .curveEaseOut, animations: {
            self.imageView.alpha = 0.0
        }, completion: { done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let viewController = LoginViewController(viewModel: AuthViewModel(service: AuthService()))
                    self.navigationController?.pushViewController(viewController, animated: false)
                }
            }
        })
    }
}

extension SplashViewController {
    func createSplashImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}
