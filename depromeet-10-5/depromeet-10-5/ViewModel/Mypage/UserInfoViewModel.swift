//
//  UserInfoViewModel.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/11/06.
//

import Combine
import UIKit

protocol UserInfoViewModelType {
    // Outputs
    var title: AnyPublisher<String, Never> { get }
}

class UserInfoViewModel: UserInfoViewModelType {
    var title: AnyPublisher<String, Never> {
        Just("계정 정보").eraseToAnyPublisher()
    }

    deinit {
        Log.debug(Self.self, #function)
    }
}
