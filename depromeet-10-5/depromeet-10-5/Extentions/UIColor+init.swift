import UIKit

extension UIColor {
    private convenience init(red: Int, green: Int, blue: Int, alpha: Int = 1) {
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha)
        )
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    convenience init(argb: Int) {
        self.init(
            red: (argb >> 16) & 0xFF,
            green: (argb >> 8) & 0xFF,
            blue: argb & 0xFF,
            alpha: (argb >> 24) & 0xFF
        )
    }
}

extension UIColor {
    var isDarkColor: Bool {
        var red, green, blue, alpha: CGFloat
        (red, green, blue, alpha) = (0, 0, 0, 0)
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let lum = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return  lum < 0.50
    }

    func add(_ color: UIColor) -> UIColor {
        var red1, green1, blue1, alpha1: CGFloat
        var red2, green2, blue2, alpha2: CGFloat
        (red1, green1, blue1, alpha1) = (0, 0, 0, 0)
        (red2, green2, blue2, alpha2) = (0, 0, 0, 0)

        getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return UIColor(red: min(red1 + red2, 1),
                       green: min(green1 + green2, 1),
                       blue: min(blue1 + blue2, 1),
                       alpha: (alpha1 + alpha2) / 2)
    }
}
