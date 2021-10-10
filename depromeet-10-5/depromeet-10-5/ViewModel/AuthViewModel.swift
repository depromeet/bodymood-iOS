//
//  AuthViewModel.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/01.
//

import Combine
import Foundation

import KakaoSDKAuth
import KakaoSDKUser

class AuthViewModel {
    func fetchKakaoLogin() -> Future<OAuthToken, Error> {
        return Future { promise in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(oauthToken!))
                    }
                }
            }
        }
    }
}
