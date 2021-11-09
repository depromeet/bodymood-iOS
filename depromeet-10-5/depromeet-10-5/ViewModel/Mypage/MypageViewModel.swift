//
//  MypageViewModel.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/11/06.
//

import UIKit
import Combine

protocol MypageViewModelType {
    // Outputs
    var title: AnyPublisher<String, Never> { get }
    var moveToUserInfo: PassthroughSubject<Void, Never> { get }
    var moveToAgreement: PassthroughSubject<Void, Never> { get }
    var moveToRemoveAccount: PassthroughSubject<Void, Never> { get }
    var moveToLogout: PassthroughSubject<Void, Never> { get }
    var userSubject: CurrentValueSubject<UserDataResponse?, Never> { get }
    func userInfo()

    // Inputs
    var backButtonDidTap: PassthroughSubject<Void, Never> { get }
    var userInfoButtonDidTap: PassthroughSubject<Void, Never> { get }
    var agreementButtonDidTap: PassthroughSubject<Void, Never> { get }
    var removeAccountButtonDidTap: PassthroughSubject<Void, Never> { get }
    var logoutButtonDidTap: PassthroughSubject<Void, Never> { get }
}

class MypageViewModel: MypageViewModelType {

    private var subscriptions = Set<AnyCancellable>()
    private var fetchSubscription: AnyCancellable?
    private var userService: UserServiceType
    var userSubject =  CurrentValueSubject<UserDataResponse?, Never>(nil)

    var title: AnyPublisher<String, Never> { Just("마이페이지").eraseToAnyPublisher()}
    let moveToUserInfo = PassthroughSubject<Void, Never>()
    let moveToAgreement = PassthroughSubject<Void, Never>()
    let moveToRemoveAccount = PassthroughSubject<Void, Never>()
    let moveToLogout = PassthroughSubject<Void, Never>()

    let backButtonDidTap =  PassthroughSubject<Void, Never>()
    let userInfoButtonDidTap = PassthroughSubject<Void, Never>()
    let agreementButtonDidTap = PassthroughSubject<Void, Never>()
    let removeAccountButtonDidTap = PassthroughSubject<Void, Never>()
    let logoutButtonDidTap = PassthroughSubject<Void, Never>()

    init(service: UserServiceType) {
        self.userService = service
        bind()
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    private func bind() {
        userInfoButtonDidTap.sink { [weak self] _ in
            self?.moveToUserInfo.send()
        }.store(in: &subscriptions)

        agreementButtonDidTap.sink { [weak self] _ in
            self?.moveToAgreement.send()
        }.store(in: &subscriptions)

        removeAccountButtonDidTap.sink { [weak self] _ in
            self?.moveToRemoveAccount.send()
        }.store(in: &subscriptions)

        logoutButtonDidTap.sink { [weak self] _ in
            self?.moveToLogout.send()
        }.store(in: &subscriptions)
    }

    func userInfo() {
        fetchSubscription = userService.userInfo().sink(receiveCompletion: { completion in
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
    
    func logout() {
        
    }
}
