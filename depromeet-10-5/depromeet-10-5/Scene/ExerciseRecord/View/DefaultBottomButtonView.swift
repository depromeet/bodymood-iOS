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

}
