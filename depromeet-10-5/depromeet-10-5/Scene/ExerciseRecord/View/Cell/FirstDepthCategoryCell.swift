import UIKit

class FirstDepthCategoryCell: UICollectionViewCell {
    
    enum Style {
        static let alpha: CGFloat = 0.7
        static let scaleOffset: CGFloat = 0.1
    }

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 18)
        view.textColor = .gray
        return view
    }()
    
    lazy var descLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12)
        view.textColor = .gray
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isLayoutMarginsRelativeArrangement = true
        contentView.addSubview(view)
        return view
    }()

    private var textColor: UIColor = .white

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
        
        textColor = parentBgColor.isDarkColor ? .white : UIColor(rgb: 0x1C1C1C)
        titleLabel.textColor = textColor.withAlphaComponent(Style.alpha)
        descLabel.textColor = textColor.withAlphaComponent(Style.alpha)
    }

    override var isSelected: Bool {
        didSet {
            let offset = Style.scaleOffset
            let size = stackView.frame.size
            let trans = CGAffineTransform.init(translationX: size.width * offset / 2, y: -size.height * offset / 2)
            let scale = CGAffineTransform(scaleX: 1 + offset, y: 1 + offset)

            stackView.transform = isSelected ? trans.concatenating(scale) : .identity
            titleLabel.textColor = textColor.withAlphaComponent(isSelected ? 1 : Style.alpha)
            descLabel.textColor = textColor.withAlphaComponent(isSelected ? 1 : Style.alpha)
        }
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

