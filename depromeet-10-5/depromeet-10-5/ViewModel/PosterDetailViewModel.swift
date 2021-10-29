import Photos
import Combine
import UIKit

protocol PosterDetailViewModelType {
    // Inputs
    var shareBtnTapped: PassthroughSubject<Void, Never> { get }
    var completeBtnTapped: PassthroughSubject<Void, Never> { get }
    
    // Outputs
    var poster: CurrentValueSubject<PHAsset?, Never> { get }
    var title: CurrentValueSubject<String, Never> { get }
    var shareBtnTitle: CurrentValueSubject<String, Never> { get }
    var showShareBottomSheet: PassthroughSubject<Void, Never> { get }
    
    var contentMode: CurrentValueSubject<PosterDetailContentMode, Never> { get }
}

class PosterDetailViewModel: PosterDetailViewModelType {

    let shareBtnTapped = PassthroughSubject<Void, Never>()
    let completeBtnTapped = PassthroughSubject<Void, Never>()

    let poster: CurrentValueSubject<PHAsset?, Never>
    let title: CurrentValueSubject<String, Never>
    let shareBtnTitle: CurrentValueSubject<String, Never>
    let showShareBottomSheet = PassthroughSubject<Void, Never>()
    let contentMode: CurrentValueSubject<PosterDetailContentMode, Never>

    private var bag = Set<AnyCancellable>()

    init(with asset: PHAsset? = nil, mode: PosterDetailContentMode, templateType: PosterTemplate.TemplateType? = nil) {
        poster = .init(asset)
        switch mode {
        case .general: title = .init(asset?.creationDate?.toString() ?? Date().toString())
        case .editing: title = .init(CommonText.posterEditTitle)
        }
        shareBtnTitle = .init(CommonText.shareBtnText)
        contentMode = .init(mode)
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

enum PosterDetailContentMode {
    case general, editing
}
