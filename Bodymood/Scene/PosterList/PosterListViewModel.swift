import Photos
import Combine
import UIKit

protocol PosterListViewModelType {
    // Outputs
    var posters: AnyPublisher<[PosterPhotoResponseModel], Never> { get }
    var title: AnyPublisher<String, Never> { get }
    var guideText: AnyPublisher<String, Never> { get }
    var guideEnglishText: AnyPublisher<String, Never> { get }
    var moveToDetail: PassthroughSubject<PosterPhotoResponseModel, Never> { get }
    var moveToTemplate: PassthroughSubject<Void, Never> { get }
    var moveToMypage: PassthroughSubject<Void, Never> { get }
    var showAlert: PassthroughSubject<String, Never> { get }

    // Inputs
    var numOfItemsPerRow: Int { get }
    var mypageBtnTapped: PassthroughSubject<Void, Never> { get }
    var addBtnTapped: PassthroughSubject<Void, Never> { get }
    var posterSelected: PassthroughSubject<Int, Never> { get }
    
    func loadImage() -> AnyPublisher<Bool, Never>
}

class PosterListViewModel: PosterListViewModelType {

    private let useCase: PosterUseCaseType
    private let postersSubject = CurrentValueSubject<[PosterPhotoResponseModel], Never>(.init())
    private var subscriptions = Set<AnyCancellable>()
    private var fetchSubscription: AnyCancellable?

    let numOfItemsPerRow = 2
    let maxNumOfItems = 100
    var posters: AnyPublisher<[PosterPhotoResponseModel], Never> { postersSubject.prefix(maxNumOfItems).eraseToAnyPublisher() }
    var title: AnyPublisher<String, Never> { Just("Bodymood").eraseToAnyPublisher() }
    var guideText: AnyPublisher<String, Never> { Just("나만의 바디무드 포스터를 만들어보세요.").eraseToAnyPublisher() }
    var guideEnglishText: AnyPublisher<String, Never> { Just("Create your own Bodymood poster.").eraseToAnyPublisher() }
    let moveToMypage = PassthroughSubject<Void, Never>()
    let moveToDetail = PassthroughSubject<PosterPhotoResponseModel, Never>()
    let moveToTemplate = PassthroughSubject<Void, Never>()
    let showAlert = PassthroughSubject<String, Never>()

    let mypageBtnTapped = PassthroughSubject<Void, Never>()
    let addBtnTapped = PassthroughSubject<Void, Never>()
    let posterSelected = PassthroughSubject<Int, Never>()

    @discardableResult
    func loadImage() -> AnyPublisher<Bool, Never> {
        let finished = CurrentValueSubject<Bool, Never>(false)
        fetchSubscription = useCase.fetch(page: 0, size: 100)
            .sink(receiveCompletion: { [weak self] completion in
                finished.send(true)
                if case let .failure(error) = completion {
                    let errorMsg = (error as? BodyMoodErrorResponse)?.message ?? error.localizedDescription
//                    self?.showAlert.send(errorMsg)
                }
            }, receiveValue: { [weak self] list in
                self?.postersSubject.send(list.posters)
            })
        return finished.eraseToAnyPublisher()
    }

    init(useCase: PosterUseCaseType) {
        self.useCase = useCase
        bind()
        loadImage()
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    private func bind() {
        mypageBtnTapped.sink { [weak self] _ in
            self?.moveToMypage.send()
        }.store(in: &subscriptions)

        addBtnTapped
            .sink { [weak self] _ in
                self?.moveToTemplate.send()
            }.store(in: &subscriptions)

        posterSelected
            .sink { [weak self] index in
                guard let poster = self?.postersSubject.value[safe: index] else { return }
                self?.moveToDetail.send(poster)
            }.store(in: &subscriptions)
    }
}
