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
    func logout() -> Future<Bool, Never>
    // Inputs
    var logoutButtonDidTap: PassthroughSubject<Void, Never> { get }
    var cancelButtonDidTap: PassthroughSubject<Void, Never> { get }
}

class LogoutViewModel: LogoutViewModelType {
    private var fetchScription: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()
    private var authService: AuthServiceType

    var title: AnyPublisher<String, Never> { Just("로그아웃을 하시겠습니까?").eraseToAnyPublisher() }
    var logoutButtonTitle: AnyPublisher<String, Never> { Just("로그아웃").eraseToAnyPublisher() }
    var cancelButtonTitle: AnyPublisher<String, Never> { Just("취소").eraseToAnyPublisher() }
    var logoutSubject: CurrentValueSubject<LogoutResponse, Never>?
    let moveToLogout = PassthroughSubject<Void, Never>()
    let moveToBack = PassthroughSubject<Void, Never>()
    let logoutButtonDidTap = PassthroughSubject<Void, Never>()
    let cancelButtonDidTap = PassthroughSubject<Void, Never>()

    init(service: AuthServiceType) {
        self.authService = service
        bind()
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    private func bind() {
        logoutButtonDidTap.sink { [weak self] _ in
            HackleTracker.track(key: "logoutConfirmButtonLogin", pageName: .logout, eventType: .click, object: .logoutConfirmButton)
            
            self?.moveToLogout.send()
        }.store(in: &subscriptions)

        cancelButtonDidTap.sink { [weak self] _ in
            HackleTracker.track(key: "logoutCancelButtonLogin", pageName: .logout, eventType: .click, object: .logoutCancelButton)
            
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

    func logout() -> Future<Bool, Never> {
        return Future { [weak self] promise in
            self?.fetchScription = self?.authService.logout().sink(receiveCompletion: { completion in

                if case let .failure(error) = completion {
                    Log.error("서버 로그아웃 실패 \(error)")
                    promise(.success(false))
                } else {
                    promise(.success(true))
                }
            }, receiveValue: { response in
                Log.debug(response.code)
                if response.code != "0000" {
                    Log.error("웹서버 로그아웃 실패")
                }
            })
        }
    }
}
