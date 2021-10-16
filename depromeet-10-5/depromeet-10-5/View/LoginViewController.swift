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

class LoginViewController: UIViewController {

    lazy var authViewModel: AuthViewModel = {
        let viewModel = AuthViewModel()
        return viewModel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    var subscription: Set<AnyCancellable> = []

    private var kakaoLoginSubscriber: AnyCancellable?
    private var accessToken: String?

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
}
