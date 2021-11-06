//
//  CameraViewModel.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/11/05.
//

import Combine
import UIKit

protocol CameraViewModelType {
    // Outputs
    var moveToPoster: PassthroughSubject<Void, Never> { get }
    var flash: PassthroughSubject<Void, Never> { get }
    var shutter: PassthroughSubject<Void, Never> { get }
    var flip: PassthroughSubject<Void, Never> { get }

    // Inputs
    var clearButtonDidTap: PassthroughSubject<Void, Never> { get }
    var flashButtonDidTap: PassthroughSubject<Void, Never> { get }
    var shutterButtonDidTap: PassthroughSubject<Void, Never> { get }
    var flipButtonDidTap: PassthroughSubject<Void, Never> { get }
}

class CameraViewModel: CameraViewModelType {
    private var subscriptions = Set<AnyCancellable>()

    let moveToPoster = PassthroughSubject<Void, Never>()
    let flash = PassthroughSubject<Void, Never>()
    let shutter = PassthroughSubject<Void, Never>()
    let flip = PassthroughSubject<Void, Never>()

    let clearButtonDidTap =  PassthroughSubject<Void, Never>()
    let flashButtonDidTap = PassthroughSubject<Void, Never>()
    let shutterButtonDidTap = PassthroughSubject<Void, Never>()
    let flipButtonDidTap = PassthroughSubject<Void, Never>()
    init() {
        bind()
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    private func bind() {
        clearButtonDidTap.sink { [weak self] _ in
            self?.moveToPoster.send()
        }.store(in: &subscriptions)

        flashButtonDidTap.sink { [weak self] _ in
            self?.flash.send()
        }.store(in: &subscriptions)

        shutterButtonDidTap.sink { [weak self] _ in
            self?.shutter.send()
        }.store(in: &subscriptions)

        flipButtonDidTap.sink { [weak self] _ in
            self?.flip.send()
        }.store(in: &subscriptions)
    }
}
