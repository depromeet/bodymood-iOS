//
//  AuthViewModel.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/01.
//

import Combine
import Foundation
import UIKit

import KakaoSDKAuth
import KakaoSDKUser

class AuthViewModel {
    private let accessTokenSubject = CurrentValueSubject<String, Never>(.init())
    private var authService: AuthService
    private var subscription: AnyCancellable?
    var accessToken: AnyPublisher<String, Never> {
        accessTokenSubject.eraseToAnyPublisher()
    }

    let kakaoBtnTapped =  PassthroughSubject<Void, Never>()

    init() {
        self.authService = AuthService()
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    func kakaoLoginAvailable() -> Future<OAuthToken, Error> {
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

    /// Server에 Access Token 보내기
    func kakaoLogin(accessToken: String) {
        subscription = authService.kakaoLogin(accessToken: accessToken).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                Log.debug("success kakaoLogin View Model")

            case .failure(let error):
                Log.error(error)
            }

        }, receiveValue: { response in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                UserDefaults.standard.setValue(response.data?.accessToken ?? "", forKey: UserDefaultKey.accessToken)
                UserDefaults.standard.setValue(response.data?.refreshToken ?? "", forKey: UserDefaultKey.refreshToken)

                self.accessTokenSubject.send(response.data?.accessToken ?? "")
            }
        })
    }

    func appleLogin(accessToken: String) {
        subscription = authService.appleLogin(accessToken: accessToken).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                Log.debug("success Apple Login View Model")
            case .failure(let error):
                Log.error(error)
            }

        }, receiveValue: { response in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                UserDefaults.standard.setValue(response.data?.accessToken, forKey: UserDefaultKey.accessToken)
                UserDefaults.standard.setValue(response.data?.refreshToken ?? "", forKey: UserDefaultKey.refreshToken)
                self.accessTokenSubject.send(response.data?.accessToken ?? "")
            }
        })
    }
}
