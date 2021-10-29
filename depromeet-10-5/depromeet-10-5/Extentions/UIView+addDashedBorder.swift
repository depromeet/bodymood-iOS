import UIKit

extension UIView {
    func addDashedBorder(with color: UIColor, lineWidth: CGFloat, cornerRadius: CGFloat) {
        let name = "\(#function)"
        layer.sublayers?.filter({$0.name == name}).first?.removeFromSuperlayer()
        
        let shapeLayer = CAShapeLayer()
        let size = frame.size
        let rect = CGRect(origin: .zero, size: size)

        shapeLayer.bounds = rect
        shapeLayer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [3, 3]
        shapeLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
        shapeLayer.name = name

        layer.addSublayer(shapeLayer)
    }
}
