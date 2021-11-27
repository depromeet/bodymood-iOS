import Photos
import Combine
import UIKit

protocol PosterDetailViewModelType {
    // Inputs
    var shareBtnTapped: PassthroughSubject<Void, Never> { get }
    var completeBtnTapped: PassthroughSubject<Void, Never> { get }
    var viewDidAppearSignal: PassthroughSubject<UIImage, Never> { get }
    // Outputs
    var poster: CurrentValueSubject<PosterPhotoResponseModel?, Never> { get }
    var makePoster: CurrentValueSubject<(UIImage, [ExerciseCategoryModel], EmotionDataResponse)?, Never> { get }
    var title: CurrentValueSubject<String, Never> { get }
    var shareBtnTitle: CurrentValueSubject<String, Never> { get }
    var showShareBottomSheet: PassthroughSubject<Void, Never> { get }
    var contentMode: CurrentValueSubject<PosterDetailContentMode, Never> { get }
}

class PosterDetailViewModel: PosterDetailViewModelType {
    
    let shareBtnTapped = PassthroughSubject<Void, Never>()
    let completeBtnTapped = PassthroughSubject<Void, Never>()
    let viewDidAppearSignal = PassthroughSubject<UIImage, Never>()

    let poster: CurrentValueSubject<PosterPhotoResponseModel?, Never>
    let title: CurrentValueSubject<String, Never>
    let shareBtnTitle: CurrentValueSubject<String, Never>
    let showShareBottomSheet = PassthroughSubject<Void, Never>()
    let contentMode: CurrentValueSubject<PosterDetailContentMode, Never>
    let makePoster = CurrentValueSubject<(UIImage, [ExerciseCategoryModel], EmotionDataResponse)?, Never>(nil)

    private var bag = Set<AnyCancellable>()
    private var fetchSubscription: Cancellable?
    
    init(with poster: PosterPhotoResponseModel? = nil, mode: PosterDetailContentMode, templateType: PosterTemplate.TemplateType? = nil) {
        self.poster = .init(poster)
        switch mode {
        case .general:
            let date = Date.fromISO8601(poster?.createdAt ?? "", withFractionalSeconds: true)
            let dateString = date?.toString()
            title = .init(dateString ?? Date().toString())
        case .editing: title = .init(Date().toString())
        }
        shareBtnTitle = .init(CommonText.shareBtnText)
        contentMode = .init(mode)
        bind()
    }

    convenience init(image: UIImage, exercises: [ExerciseCategoryModel], emotion: EmotionDataResponse) {
        self.init(mode: .editing)
        makePoster.send((image, exercises, emotion))
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    private func bind() {
        shareBtnTapped
            .sink { [weak self] _ in
                self?.showShareBottomSheet.send()
            }.store(in: &bag)

        makePoster
            .compactMap { $0 }
            .zip(viewDidAppearSignal)
            .first()
            .flatMap { tmp -> AnyPublisher<PosterAddResponseModel, Error> in
                let ((originImage, exerciseList, emotion), posterImage) = tmp
                let model = PosterAddRequestModel(posterImage: posterImage,
                                                  originImage: originImage,
                                                  emotion: emotion.englishTitle ?? "",
                                                  categories: exerciseList.map { $0.categoryId })
                return BodyMoodAPIService.shared.addPoster(model)
            }.sink { completion in
                switch completion {
                case .finished:
                    Log.debug("저장성공")
                case .failure(let error):
                    Log.debug("저장실패", error)
                }
            } receiveValue: { _ in
            }.store(in: &bag)
    }
}

enum PosterDetailContentMode {
    case general, editing
}
