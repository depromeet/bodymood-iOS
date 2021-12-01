//
//  SplashViewModel.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/11/10.
//

import Foundation
import Combine

protocol SplashViewModelType {
    func userInfo()
}

class SplashViewModel: SplashViewModelType {
    private var fetchSubscription: AnyCancellable?
    private var userService: UserServiceType
    var userSubject = CurrentValueSubject<UserDataResponse?, Never>(nil)
    
    init(userService: UserServiceType) {
        self.userService = userService
        userInfo()
    }
    
    deinit {
        Log.debug(Self.self, #function)
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
}
