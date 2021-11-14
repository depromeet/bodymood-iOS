import UIKit

class DefaultBottomButton: UIButton {
    enum Style {
        static let normalBGColor = UIColor(rgb: 0x1C1C1C)
        static let disabledBGColor = UIColor(rgb: 0xAAAAAA)
        static let highlightedTextColor = UIColor(rgb: 0xAAAAAA)
        static let normalTextColor = UIColor.white
    }

    lazy var label: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16)
        view.textColor = Style.normalTextColor
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()

    init() {
        super.init(frame: .zero)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            label.textColor = isHighlighted ? Style.highlightedTextColor : Style.normalTextColor
        }
    }

    @available(*, unavailable, message: "set title using label property")
    override func setTitle(_ title: String?, for state: UIControl.State) {}

    private func style() {
        setBackgroundColor(Style.disabledBGColor, for: [.disabled])
        setBackgroundColor(Style.normalBGColor, for: [.normal, .highlighted])
    }

    private func layout() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            label.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return bounds.contains(point) ? self : nil
    }
}

class BottomButtonListView: UIView {
    enum Style {
        static let normalBGColor = UIColor(rgb: 0x1C1C1C)
        static let disabledBGColor = UIColor(rgb: 0xAAAAAA)
        static let highlightedTextColor = UIColor(rgb: 0xAAAAAA)
        static let normalTextColor = UIColor.white
    }

    var buttons: [UIButton] {
        get {
            buttonStackView.arrangedSubviews.compactMap { $0 as? UIButton }
        }
    }

    func setButtonImages(_ list: [UIImage?]) {
        buttonStackView.removeAllArrangedSubviews()
        list.forEach {
            let button = UIButton()
            button.setImage($0, for: .normal)
            buttonStackView.addArrangedSubview(button)
        }
    }

    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 70
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .init(top: 14, left: 0, bottom: 14, right: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()

    init() {
        super.init(frame: .zero)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {

        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: topAnchor),
            buttonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
}
