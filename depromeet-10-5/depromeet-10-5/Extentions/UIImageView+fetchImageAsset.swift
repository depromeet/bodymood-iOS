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

    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async { [weak self] in
                self?.image = image
            }
        }.resume()
    }

    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
