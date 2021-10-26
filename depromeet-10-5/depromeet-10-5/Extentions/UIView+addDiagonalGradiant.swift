import UIKit

extension UIView {
    func addDiagonalGradiant(startColor: UIColor, endColor: UIColor) {
        let gradientLayerName = "gradientLayer"

        if let oldlayer = layer.sublayers?.filter({$0.name == gradientLayerName}).first {
            oldlayer.removeFromSuperlayer()
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = .init(x: 0, y: 0)
        gradientLayer.endPoint = .init(x: 1, y: 1)
        gradientLayer.frame = bounds
        gradientLayer.name = gradientLayerName

        layer.insertSublayer(gradientLayer, at: 0)
    }
}
