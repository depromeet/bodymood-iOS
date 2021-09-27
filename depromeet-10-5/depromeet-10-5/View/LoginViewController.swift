//
//  LoginViewController.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/09/28.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func kakaoLoginDidTap(_ sender: Any) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print(error)
                } else {
                   print("loginWithKakaotalk() success")
                    _ = oauthToken
                }
            }
        }
    }
}
