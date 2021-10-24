import Photos
import Combine
import UIKit

protocol PosterDetailViewModelType {
    // Inputs
    var shareBtnTapped: PassthroughSubject<Void, Never> { get }
    
    // Outputs
    var poster: CurrentValueSubject<PHAsset, Never> { get }
    var title: CurrentValueSubject<String, Never> { get }
    var shareBtnTitle: CurrentValueSubject<String, Never> { get }
    var showShareBottomSheet: PassthroughSubject<Void, Never> { get }
}

class PosterDetailViewModel: PosterDetailViewModelType {
    let shareBtnTapped = PassthroughSubject<Void, Never>()

    let poster: CurrentValueSubject<PHAsset, Never>
    let title: CurrentValueSubject<String, Never>
    let shareBtnTitle: CurrentValueSubject<String, Never>
    let showShareBottomSheet = PassthroughSubject<Void, Never>()
    
    private var bag = Set<AnyCancellable>()

    init(with asset: PHAsset) {
        poster = .init(asset)
        shareBtnTitle = .init(CommonText.shareBtnText)
        title = .init(asset.creationDate?.toString() ?? "")

        bind()
    }
    deinit {
        Log.debug(Self.self, #function)
    }

    private func bind() {
        shareBtnTapped
            .sink { [weak self] _ in
                self?.showShareBottomSheet.send()
            }.store(in: &bag)
    }
}
