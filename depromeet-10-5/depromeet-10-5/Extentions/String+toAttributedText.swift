import Foundation
import UIKit

extension String {
    func toAttributedText(minimumLineHeight: CGFloat, alignment: NSTextAlignment = .natural) -> NSAttributedString {
        let result = NSMutableAttributedString(string: self)
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = minimumLineHeight
        style.alignment = alignment
        style.lineBreakMode = .byTruncatingTail
        let range = NSRange(location: 0, length: result.length)
        result.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
        return result
    }
}
