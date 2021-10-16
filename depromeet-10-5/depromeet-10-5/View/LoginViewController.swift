//
//  LoginViewController.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/09/28.
//

import Combine
import UIKit

import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

class LoginViewController: UIViewController, AuthCoordinating {
    
    var coordinator: AuthCoordinatorProtocol?
    
    lazy var authViewModel: AuthViewModel = {
        let viewModel = AuthViewModel()
        return viewModel
    }()
    
    var subscription: Set<AnyCancellable> = []

    private var kakaoLoginSubscriber: AnyCancellable?
    private var accessToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        title = "Login"
        
        let button: UIButton = {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 220, height: 55))
            view.addSubview(button)
            button.center = view.center
            button.backgroundColor = .systemGreen
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
            return button
        }()
    }

    @objc func buttonDidTap() {
        coordinator?.eventOccured(with: .buttonDidTap)
    }
    
    @IBAction func kakaoLoginButtonDidTap(_ sender: Any) {
        let kakaoLoginFuture = authViewModel.loginAvailable()

        _ = kakaoLoginFuture.sink( receiveCompletion: { completion in
            switch completion {
                case .finished:
                self.authViewModel.kakaoAuth(accessToken: self.accessToken ?? "")
                case .failure(let error):
                    Log.debug(error)
                }
            }, receiveValue: {
                Log.debug("====\($0.accessToken)====")
                self.accessToken = $0.accessToken
            }).store(in: &subscription)
    }

    @IBAction func kakaoLogoutButtonDidTap(_ sender: Any) {
        UserApi.shared.logout(completion: { error in
            if let error = error {
                Log.error(error)
            } else {
                Log.debug("log out success")
            }
        })
    }
	
	
	// TODO: 제거할 것
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			presentAlbumVC(on: self)
		}
	}
}
