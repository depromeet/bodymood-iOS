import Combine
import UIKit

protocol RemoveAccountViewModelType {
    // Outputs
    var title: AnyPublisher<String, Never> { get }
}

class RemoveAccountViewModel: RemoveAccountViewModelType {
    var title: AnyPublisher<String, Never> {
        Just("계정 탈퇴").eraseToAnyPublisher()
    }

    deinit {
        Log.debug(Self.self, #function)
    }
}
