import Photos
import Combine
import UIKit

protocol AlbumViewModelType {
	var numOfItemsPerRow: Int { get }
	var photos: AnyPublisher<[PHAsset], Never> { get }
	var title: AnyPublisher<String, Never> { get }
	var nextBtnTitle: AnyPublisher<String, Never> { get }

	var nextBtnTapped: PassthroughSubject<IndexPath, Never> { get }
	var backBtnTapped: PassthroughSubject<Void, Never> { get }

	func loadImage() -> AnyPublisher<Bool, Never>
}

class AlbumViewModel: AlbumViewModelType {
	private let useCase: AlbumUseCaseType
	private let photosSubject = CurrentValueSubject<[PHAsset], Never>(.init())
	private var subscriptions = Set<AnyCancellable>()
	private var fetchSubscription: AnyCancellable?

	let numOfItemsPerRow = 3
	var photos: AnyPublisher<[PHAsset], Never> { photosSubject.eraseToAnyPublisher() }
	var title: AnyPublisher<String, Never> { Just("앨범").eraseToAnyPublisher() }
	var nextBtnTitle: AnyPublisher<String, Never> { Just("Next").eraseToAnyPublisher() }

	let nextBtnTapped = PassthroughSubject<IndexPath, Never>()
	let backBtnTapped = PassthroughSubject<Void, Never>()

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

	init(useCase: AlbumUseCaseType) {
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
				// TODO: 다음 버튼 액션 처리 (ex.VC 전환)
				guard let self = self else { return }
				let selectedItem = self.photosSubject.value[indexPath.item]
				Log.debug("nextBtnTapped", indexPath, selectedItem)
			}.store(in: &subscriptions)

		backBtnTapped
			.sink { _ in
				// TODO: 뒤로가기 버튼 액션 처리 (ex. dismiss)
				Log.debug("backBtnTapped")
			}.store(in: &subscriptions)
	}
}
