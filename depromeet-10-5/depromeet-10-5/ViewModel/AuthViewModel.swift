//
//  AuthViewModel.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/01.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser

class AuthViewModel {
    func fetchKakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    Log.error(error)
                } else {
                    Log.debug("loginWithKakaotalk() success")
                    _ = oauthToken
                }
            }
        }
    }
}
