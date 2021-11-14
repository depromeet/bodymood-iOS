import Combine
import Foundation
import UIKit

protocol EmotionViewModelType {
    var buttonTitle: CurrentValueSubject<String, Never> { get }
    var canEnableButton: CurrentValueSubject<Bool, Never> { get }
    var selectButtonDidTap: PassthroughSubject<Void, Never> { get }
    var canShowButton: CurrentValueSubject<Bool, Never> { get }
    var itemTapped: PassthroughSubject<Int, Never> { get }
}

class EmotionViewModel: EmotionViewModelType {

    private var emotionService: EmotionServiceType
    private var subscriptions = Set<AnyCancellable>()
    private var fetchSubscription: AnyCancellable?
    private var emotionSubject = CurrentValueSubject<[EmotionDataResponse], Never>(.init())

    var emotions: [EmotionResponse] = []
    var buttonTitle =  CurrentValueSubject<String, Never>("감정 선택")
    var canEnableButton = CurrentValueSubject<Bool, Never>(false)
    var canShowButton = CurrentValueSubject<Bool, Never>(false)

    let selectButtonDidTap = PassthroughSubject<Void, Never>()
    let itemTapped = PassthroughSubject<Int, Never>()

    init(service: EmotionServiceType) {
        self.emotionService = service
        bind()
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    private func bind() {
        itemTapped.sink { [weak self] _ in
            self?.buttonTitle.send("선택 완료")
            self?.canEnableButton.send(true)
        }.store(in: &subscriptions)
    }
}
