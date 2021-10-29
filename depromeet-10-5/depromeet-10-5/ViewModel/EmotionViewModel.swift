//
//  EmotionViewModel.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/26.
//

import Combine
import Foundation
import UIKit

protocol EmotionViewModelType {
    var buttonTitle: CurrentValueSubject<String, Never> { get }
    var canEnableButton: CurrentValueSubject<Bool, Never> { get }
    var selectButtonDidTap: PassthroughSubject<Void, Never> { get }

    func emotionCategories() -> AnyPublisher<[EmotionDataResponse], Never>
}

class EmotionViewModel: EmotionViewModelType {
    private var emotionService: EmotionServiceType
    private var subscriptions = Set<AnyCancellable>()
    private var fetchSubscription: AnyCancellable?
    private var emotionSubject = CurrentValueSubject<[EmotionDataResponse], Never>(.init())

    var emotions: [EmotionResponse] = []
    var buttonTitle =  CurrentValueSubject<String, Never>("선택 완료")
    var canEnableButton = CurrentValueSubject<Bool, Never>(true)

    let selectButtonDidTap = PassthroughSubject<Void, Never>()

    init(service: EmotionServiceType) {
        self.emotionService = service
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    func emotionCategories() -> AnyPublisher<[EmotionDataResponse], Never> {
        fetchSubscription = emotionService.emotionCategories().sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                Log.debug("success emotion categories")

            case .failure(let error):
                Log.error(error)
            }
        }, receiveValue: { response in
            self.emotionSubject.send(response.data ?? [])

        })

        return emotionSubject.eraseToAnyPublisher()
    }
}
