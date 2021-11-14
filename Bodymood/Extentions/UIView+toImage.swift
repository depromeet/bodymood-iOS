import UIKit

extension UIView {
    func toImage(with size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        drawHierarchy(in: .init(origin: .zero, size: size), afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
