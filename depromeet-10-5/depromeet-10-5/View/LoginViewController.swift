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

    var accessToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func kakaoLoginButtonDidTap(_ sender: Any) {
        let kakaoLoginFuture = authViewModel.fetchKakaoLogin()

        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            _ = kakaoLoginFuture.sink {
                Log.debug($0)
            } receiveValue: {
                Log.debug($0.accessToken)
            }
        }
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
