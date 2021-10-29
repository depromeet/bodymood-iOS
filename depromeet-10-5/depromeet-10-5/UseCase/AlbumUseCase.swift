import Photos
import Combine

protocol AlbumUseCaseType {
	func fetch() -> AnyPublisher<[PHAsset], Never>
}

class AlbumUseCase: AlbumUseCaseType {

	func fetch() -> AnyPublisher<[PHAsset], Never> {
		requestAuthorization().map { [weak self] authrized in
			authrized ? self?.fetchAssets() ?? [] : []
		}.eraseToAnyPublisher()
	}

	private func fetchAssets() -> [PHAsset] {
		let options = PHFetchOptions()
		options.sortDescriptors = [
			NSSortDescriptor(
				key: "creationDate",
				ascending: false)
		]
		options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

		var assets = [PHAsset]()
		PHAsset.fetchAssets(with: options).enumerateObjects { asset, _, _ in
			assets.append(asset)
		}
		return assets
	}

	private func requestAuthorization() -> AnyPublisher<Bool, Never> {
		return Deferred {
			Future { promise in
				let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
				switch status {
				case .authorized, .limited:
					promise(.success(true))
				case .notDetermined:
					PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
						let list: [PHAuthorizationStatus] = [.authorized, .limited]
						promise(.success(list.contains(status) ? true : false))
					}
				default:
					promise(.success(false))
				}
			}
		}.eraseToAnyPublisher()
	}
}
