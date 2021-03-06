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
    var loginIsSuccess: PassthroughSubject<Bool, Never> { get }
    func kakaoLoginAvailable(isTalk: Bool) -> Future<OAuthToken, Error>
    var userSubject: CurrentValueSubject<UserDataResponse?, Never> { get }
    func kakaoLogin(accessToken: String)
    func appleLogin(accessToken: String)
    func userInfo()
}

class LoginViewModel: LoginViewModelType {
    
    private let accessTokenSubject = CurrentValueSubject<String, Never>(.init())
    var userSubject =  CurrentValueSubject<UserDataResponse?, Never>(nil)
    var loginisSuccess =  PassthroughSubject<Bool, Never>()

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
    let loginIsSuccess = PassthroughSubject<Bool, Never>()

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

    func kakaoLoginAvailable(isTalk: Bool) -> Future<OAuthToken, Error> {
        if isTalk {
            return Future { [weak self] promise in
                if UserApi.isKakaoTalkLoginAvailable() {
                    UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(oauthToken!))
                        }
                    }
                } else {
                    self?.loginisSuccess.send(false)
                }
            }
        }
        
        return Future { promise in
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(oauthToken!))
                }
            }
        }
    }

    func kakaoLogin(accessToken: String) {
        fetchSubscription = authService.kakaoLogin(accessToken: accessToken)
            .sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                self?.loginIsSuccess.send(true)
                Log.debug("success with kakao login")

            case .failure(let error):
                self?.loginIsSuccess.send(false)
                Log.error(error)
            }

        }, receiveValue: { [weak self] response in
            Log.debug(response.code)
            self?.valueDidReceived(response: response)
        })
    }

    func appleLogin(accessToken: String) {
        fetchSubscription = authService.appleLogin(accessToken: accessToken).sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                Log.debug("success Apple Login View Model")
                
            case .failure(let error):
                self?.loginIsSuccess.send(false)
                Log.error(error)
            }

        }, receiveValue: { [weak self] response in
            self?.loginisSuccess.send(true)
            self?.valueDidReceived(response: response)
        })
    }

    private func valueDidReceived(response: AuthResponse) {
        guard let accessToken = response.data?.accessToken,
            let refreshToken = response.data?.refreshToken else {
                return
            }

        saveTokens(accessToken: accessToken, refreshToken: refreshToken)
        moveToPoster.send()
    }

    private func saveTokens(accessToken: String, refreshToken: String) {
        UserDefaults.standard.setValue(accessToken, forKey: UserDefaultKey.accessToken)
        UserDefaults.standard.setValue(refreshToken, forKey: UserDefaultKey.refreshToken)
        self.accessTokenSubject.send(accessToken)
    }

    func userInfo() {
        fetchSubscription = UserService().userInfo().sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                Log.debug("success getting user info")
            case .failure(let error):
                Log.error(error)
            }
        }, receiveValue: { [weak self] response in
            
            self?.userSubject.send(response.data)
            
            UserDefaults.standard.setValue(response.data.name, forKey: UserDefaultKey.userName)
            UserDefaults.standard.setValue(response.data.socialProvider, forKey: UserDefaultKey.socialProvider)
        })
    }
}
