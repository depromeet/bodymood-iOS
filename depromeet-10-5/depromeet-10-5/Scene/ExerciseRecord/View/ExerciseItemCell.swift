import UIKit

class ExerciseItemCell: UICollectionViewCell {

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 14)
        view.textColor = .white
        return view
    }()

    lazy var descLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12)
        view.textColor = .white
        return view
    }()

    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = .init(top: 8, left: 0, bottom: 8, right: 0)
        view.isLayoutMarginsRelativeArrangement = true
        contentView.addSubview(view)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with model: ExerciseItemModel, parentBgColor: UIColor) {
        titleLabel.text = model.english
        descLabel.text = model.korean

        let textColor: UIColor = parentBgColor.isDarkColor ? .white : .black
        titleLabel.textColor = textColor
        descLabel.textColor = textColor
    }

    override var isSelected: Bool {
        didSet {
            stackView.transform = isSelected ? .init(translationX: 24, y: 0) : .identity
            contentView.backgroundColor = isSelected ? .gray.withAlphaComponent(0.2) : .clear
        }
    }

    private func layout() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

