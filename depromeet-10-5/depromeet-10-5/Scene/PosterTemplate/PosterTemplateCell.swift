import UIKit
import Photos

class PosterTemplateCell: UICollectionViewCell {

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.black.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 3 : 0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with imageName: String) {
        imageView.image = UIImage(named: imageName)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    private func layout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
