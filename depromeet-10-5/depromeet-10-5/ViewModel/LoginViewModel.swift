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

protocol LoginViewModelType {
    var accessToken: AnyPublisher<String, Never> { get }
    var kakaoLoginButtonDidTap: PassthroughSubject<Void, Never> { get }
    var appleLoginButtonDidTap: PassthroughSubject<Void, Never> { get }
    var developerLoginButtonDidTap: PassthroughSubject<Void, Never> { get }
    var moveToPoster: PassthroughSubject<Void, Never> { get }
    func kakaoLoginAvailable() -> Future<OAuthToken, Error>
    func kakaoLogin(accessToken: String)
    func appleLogin(accessToken: String)
}

class LoginViewModel: LoginViewModelType {
    
    private let accessTokenSubject = CurrentValueSubject<String, Never>(.init())
    private var authService: AuthServiceType
    private var fetchSubscription: AnyCancellable?
    private var subscriptions =  Set<AnyCancellable>()
    var accessToken: AnyPublisher<String, Never> {
        accessTokenSubject.eraseToAnyPublisher()
    }

    let kakaoLoginButtonDidTap =  PassthroughSubject<Void, Never>()
    let appleLoginButtonDidTap = PassthroughSubject<Void, Never>()
    let developerLoginButtonDidTap = PassthroughSubject<Void, Never>()
    let moveToPoster = PassthroughSubject<Void, Never>()

    init(service: AuthServiceType) {
        self.authService = service
        bind()
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    private func bind() {
        kakaoLoginButtonDidTap.sink { [weak self] _ in
            self?.moveToPoster.send()
        }.store(in: &subscriptions)

        appleLoginButtonDidTap.sink { [weak self] _ in
            self?.moveToPoster.send()
        }.store(in: &subscriptions)
        
        developerLoginButtonDidTap.setFailureType(to: Error.self)
            .combineLatest(BodyMoodAPIService.shared.getTestToken())
            .map { $0.1 }
            .sink { _ in
            } receiveValue: { [weak self] model in
                self?.saveTokens(accessToken: model.accessToken, refreshToken: model.refreshToken)
                self?.moveToPoster.send()
            }.store(in: &subscriptions)

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

    func kakaoLogin(accessToken: String) {
        fetchSubscription = authService.kakaoLogin(accessToken: accessToken)
            .sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                Log.debug("success with kakao login")

            case .failure(let error):
                Log.error(error)
            }

        }, receiveValue: { response in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                let accessToken = response.data?.accessToken ?? ""
                let refreshToken = response.data?.refreshToken ?? ""

                self.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
            }
        })
    }

    func appleLogin(accessToken: String) {
        fetchSubscription = authService.appleLogin(accessToken: accessToken).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                Log.debug("success Apple Login View Model")
            case .failure(let error):
                Log.error(error)
            }

        }, receiveValue: { response in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                let accessToken = response.data?.accessToken ?? ""
                let refreshToken = response.data?.refreshToken ?? ""

                self.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
            }
        })
    }

    private func saveTokens(accessToken: String, refreshToken: String) {
        UserDefaults.standard.setValue(accessToken, forKey: UserDefaultKey.accessToken)
        UserDefaults.standard.setValue(refreshToken, forKey: UserDefaultKey.refreshToken)
        self.accessTokenSubject.send(accessToken)
    }
}
