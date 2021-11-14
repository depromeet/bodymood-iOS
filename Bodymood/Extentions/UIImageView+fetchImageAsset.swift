import UIKit
import Photos

extension UIImageView {
    static let cache = NSCache<NSString, UIImage>()

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

    func fetchImage(from url: URL,
                    resultHandler: @escaping (UIImage?) -> Void) {
        let key = NSString(string: url.absoluteString)
        
        if let image = Self.cache.object(forKey: key) {
            DispatchQueue.main.async { resultHandler(image) }
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            let image: UIImage?
            if let httpURLResponse = response as? HTTPURLResponse,
               httpURLResponse.statusCode == 200,
               let mimeType = response?.mimeType,
               mimeType.hasPrefix("image"),
               let data = data, error == nil {
                image = UIImage(data: data)
            } else {
                image = nil
            }
            
            if let image = image {
                Self.cache.setObject(image, forKey: key)
            }

            DispatchQueue.main.async { resultHandler(image) }
        }.resume()
    }

    func fetchImage(from urlString: String,
                    resultHandler: @escaping (UIImage?) -> Void) {
        if let url = URL(string: urlString) {
            fetchImage(from: url, resultHandler: resultHandler)
        } else {
            resultHandler(nil)
        }
    }
}
