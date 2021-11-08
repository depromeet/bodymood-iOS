import UIKit
import Combine

import KakaoSDKAuth
import KakaoSDKUser

protocol LogoutViewModelType {
    // Outputs
    var title: AnyPublisher<String, Never> { get }
    var logoutButtonTitle: AnyPublisher<String, Never> { get }
    var cancelButtonTitle: AnyPublisher<String, Never> { get }
    var moveToLogout: PassthroughSubject<Void, Never> { get }
    var moveToBack: PassthroughSubject<Void, Never> { get }
    func kakaoLogout() -> Future<Bool, Error>

    // Inputs
    var logoutButtonDidTap: PassthroughSubject<Void, Never> { get }
    var cancelButtonDidTap: PassthroughSubject<Void, Never> { get }
}

class LogoutViewModel: LogoutViewModelType {
    private var subscriptions = Set<AnyCancellable>()
    var title: AnyPublisher<String, Never> { Just("로그아웃을 하시겠습니까?").eraseToAnyPublisher() }
    var logoutButtonTitle: AnyPublisher<String, Never> { Just("로그아웃").eraseToAnyPublisher() }
    var cancelButtonTitle: AnyPublisher<String, Never> { Just("취소").eraseToAnyPublisher() }
    let moveToLogout = PassthroughSubject<Void, Never>()
    let moveToBack = PassthroughSubject<Void, Never>()
    let logoutButtonDidTap = PassthroughSubject<Void, Never>()
    let cancelButtonDidTap = PassthroughSubject<Void, Never>()

    init() {
        bind()
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    private func bind() {
        logoutButtonDidTap.sink { [weak self] _ in
            self?.moveToLogout.send()
        }.store(in: &subscriptions)

        cancelButtonDidTap.sink { [weak self] _ in
            self?.moveToBack.send()
        }.store(in: &subscriptions)
    }

    func kakaoLogout() -> Future<Bool, Error> {
        return Future { promise in
            UserApi.shared.logout { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(true))
                }
            }
        }
    }
}
