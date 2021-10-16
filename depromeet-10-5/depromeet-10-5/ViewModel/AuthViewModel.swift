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
    var authService: AuthService?
    var subscription: Cancellable?
    
    private var kakaoAuthSubscriber: AnyCancellable?

    init() {
        self.authService = AuthService()
    }

    deinit {
        Log.debug("viewModel \(Self.self) deallocated")
    }
    

    func loginAvailable() -> Future<OAuthToken, Error> {
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
    func kakaoAuth(accessToken: String) {
        
        subscription = authService?.kakaoAuth(accessToken: accessToken).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                Log.debug("success kakaoAuth View Model")
            
            case .failure(let error):
                Log.error(error)
            }
        }, receiveValue: { response in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                Log.debug("=== acess token \(response.data.accessToken)=====")
            }
        })
    
        
//        Log.debug("=====kakaoAuth: \(accessToken)")
//        authService?.kakaoAuth(accessToken: accessToken)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished:
//                    Log.debug("finished kakao login")
//                case .failure(let error):
//                    Log.debug("Error: \(error.localizedDescription)")
//                }
//            }, receiveValue: { object in
//                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
//                    Log.debug("received value \(object.message), \(object.code) , \(object.data?.socialId ?? "")")
//                }
//            }).store(in: &subscriptions)
    }
}
