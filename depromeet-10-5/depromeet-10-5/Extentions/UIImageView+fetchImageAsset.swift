import UIKit
import Photos

extension UIImageView {
    func fetchImageAsset(
        _ asset: PHAsset,
        frameSize: CGSize? = nil,
        options: PHImageRequestOptions? = nil,
        resultHandler: @escaping (UIImage?, [AnyHashable: Any]?) -> Void
    ) {
        let targetSize: CGSize
        if let size = frameSize {
            let scale: CGFloat = UIScreen.main.scale
            targetSize = .init(width: size.width * scale, height: size.height * scale)
        } else {
            targetSize = PHImageManagerMaximumSize
        }

        let options = PHImageRequestOptions()
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        
        options.progressHandler = {  (progress, error, stop, info) in
            Log.debug("progress: \(progress)")
        }

        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options,
            resultHandler: resultHandler)
    }
}
