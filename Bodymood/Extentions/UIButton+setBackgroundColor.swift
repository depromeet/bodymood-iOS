import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for states: [UIControl.State]) {
        let size = CGSize(width: 1, height: 1)
        let bgImage = UIGraphicsImageRenderer(size: size).image { _ in
            color.setFill()
            UIBezierPath(rect: .init(origin: .zero, size: size)).fill()
        }
        states.forEach { setBackgroundImage(bgImage, for: $0) }
    }
}
