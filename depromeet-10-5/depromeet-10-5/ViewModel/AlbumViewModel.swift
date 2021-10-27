import Photos
import Combine
import UIKit

protocol AlbumViewModelType {
	var numOfItemsPerRow: Int { get }
	var photos: AnyPublisher<[PHAsset], Never> { get }
	var title: AnyPublisher<String, Never> { get }
	var selectBtnTitle: AnyPublisher<String, Never> { get }

	var nextBtnTapped: PassthroughSubject<IndexPath, Never> { get }

	func loadImage() -> AnyPublisher<Bool, Never>
}

class AlbumViewModel: AlbumViewModelType {
    private let resultReceiver: PassthroughSubject<PHAsset, Never>
	private let useCase: AlbumUseCaseType
	private let photosSubject = CurrentValueSubject<[PHAsset], Never>(.init())
	private var subscriptions = Set<AnyCancellable>()
	private var fetchSubscription: AnyCancellable?

	let numOfItemsPerRow = 4
	var photos: AnyPublisher<[PHAsset], Never> { photosSubject.eraseToAnyPublisher() }
	var title: AnyPublisher<String, Never> { Just("앨범").eraseToAnyPublisher() }
	var selectBtnTitle: AnyPublisher<String, Never> { Just("선택").eraseToAnyPublisher() }

	let nextBtnTapped = PassthroughSubject<IndexPath, Never>()

	@discardableResult
	func loadImage() -> AnyPublisher<Bool, Never> {
		let finished = CurrentValueSubject<Bool, Never>(false)
		fetchSubscription = useCase.fetch()
			.sink { [weak self] assets in
				self?.photosSubject.send(assets)
				finished.send(true)
			}
		return finished.eraseToAnyPublisher()
	}

    init(useCase: AlbumUseCaseType, resultReciever: PassthroughSubject<PHAsset, Never>) {
        self.resultReceiver = resultReciever
		self.useCase = useCase
		bind()
		loadImage()
	}

	deinit {
		Log.debug(Self.self, #function)
	}

	private func bind() {
		nextBtnTapped
			.sink { [weak self] indexPath in
				guard let self = self else { return }
				let selectedItem = self.photosSubject.value[indexPath.item]
                self.resultReceiver.send(selectedItem)
			}.store(in: &subscriptions)
	}
}
