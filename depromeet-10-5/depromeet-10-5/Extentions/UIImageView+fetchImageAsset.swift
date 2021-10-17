import UIKit
import Photos

extension UIImageView {
	@discardableResult
	func fetchImageAsset(
		_ asset: PHAsset,
		frameSize: CGSize? = nil,
		options: PHImageRequestOptions? = nil
	) -> PHImageRequestID {
			let targetSize: CGSize
			if let size = frameSize {
				let scale = UIScreen.main.scale
				targetSize = .init(width: size.width * scale, height: size.height * scale)
			} else {
				targetSize = PHImageManagerMaximumSize
			}

			let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { image, _ in
				DispatchQueue.main.async {
					self.image = image
				}
			}

			return PHImageManager.default().requestImage(
				for: asset,
				   targetSize: targetSize,
				   contentMode: .aspectFill,
				   options: options,
				   resultHandler: resultHandler)
		}
}
