import UIKit

class CheckBoxView: UIView {
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [imageView, label])
        view.spacing = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = ImageResource.check?.withTintColor(#colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1), renderingMode: .alwaysTemplate)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()

    private lazy var label: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 14)
        view.textColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()

    var text: String = "" {
        didSet {
            label.text = text
        }
    }

    override var tintColor: UIColor? {
        didSet {
            label.textColor = tintColor
            imageView.tintColor = tintColor
        }
    }

    init() {
        super.init(frame: .zero)

        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

