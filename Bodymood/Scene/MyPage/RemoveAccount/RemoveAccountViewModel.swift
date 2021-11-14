import Combine
import UIKit

import KakaoSDKAuth
import KakaoSDKUser

protocol RemoveAccountViewModelType {
    // Outputs
    var title: AnyPublisher<String, Never> { get }
    var content: AnyPublisher<String, Never> { get }
    var removeButton: AnyPublisher<String, Never> { get }
    var removeAccountIsSuccess: PassthroughSubject<Bool, Never> { get }
    
    // Inputs
    var removeButtonDidTap: PassthroughSubject<Void, Never> { get }
    var moveToLogin: PassthroughSubject<Void, Never> { get}
    func removeAccount() -> Future<Bool, Never>
}

class RemoveAccountViewModel: RemoveAccountViewModelType {
    private var subscriptions = Set<AnyCancellable>()
    private var authService: AuthServiceType
    private var fetchSubscription: AnyCancellable?
    
    var title: AnyPublisher<String, Never> {
        Just("계정 삭제").eraseToAnyPublisher() }
    var content: AnyPublisher< String, Never> {
        Just("계정을 삭제하시겠습니까?\n삭제 후 데이터는 복구되지 않습니다.").eraseToAnyPublisher() }
    var removeButton: AnyPublisher<String, Never> { Just("계정 삭제").eraseToAnyPublisher() }
    var removeAccountIsSuccess =  PassthroughSubject<Bool, Never>()
    
    let removeButtonDidTap = PassthroughSubject<Void, Never>()
    let moveToLogin = PassthroughSubject<Void, Never>()
    
    init(service: AuthServiceType) {
        self.authService = service
        bind()
    }
    
    deinit {
        Log.debug(Self.self, #function)
    }
    
    private func bind() {
        removeButtonDidTap.sink { [weak self] _ in
            self?.removeButtonDidTap.send()
        }.store(in: &subscriptions)
    }
    
    func removeAccount() -> Future<Bool, Never> {
        return Future { [weak self] promise in
            self?.fetchSubscription = self?.authService.removeAccount().sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        Log.debug("success removing an account")
                        promise(.success(true))
                        
                    case .failure(let error):
                        Log.error(error)
                        promise(.success(false))
                    }
                }, receiveValue: { [weak self] response in
                    Log.debug(response.code)
                    if response.code != "0000" {
                        Log.error("계정 삭제 실패")
                    } else {
                        if UserDefaults.standard.string(forKey: UserDefaultKey.socialProvider) == "KAKAO" {
                            self?.removeAccountFromKakao()
                        } else {
                            self?.removeAccountIsSuccess.send(true)
                        }
                    }
                })
        }
    }
    
    func removeAccountFromKakao() {
        UserApi.shared.unlink(completion: { [weak self] error in
            
            if let error = error {
                Log.error(error)
            } else {
                Log.debug("카카오 계정 끊기 성공")
                self?.removeAccountIsSuccess.send(true)
            }
        })
    }
}
