import Combine
import UIKit

protocol AgreementViewModelType {
    // Outputs
    var title: AnyPublisher<String, Never> { get }
}

class AgreementViewModel: AgreementViewModelType {
    var title: AnyPublisher<String, Never> {
        Just("개인정보 약관 동의").eraseToAnyPublisher()
    }

    deinit {
        Log.debug(Self.self, #function)
    }
}
