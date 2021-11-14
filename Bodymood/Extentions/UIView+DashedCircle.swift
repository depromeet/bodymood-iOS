import UIKit

extension UIView {
    func addDashedCircle(startColor: UIColor) {
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        circleLayer.lineWidth = 1.0
        circleLayer.strokeColor =  UIColor.white.cgColor
        circleLayer.fillColor = startColor.cgColor
        circleLayer.lineJoin = .round
        circleLayer.lineDashPattern = [2, 2]
        layer.addSublayer(circleLayer)
    }
}

