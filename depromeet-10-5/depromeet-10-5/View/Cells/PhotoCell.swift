import UIKit
import Photos

class PhotoCell: UICollectionViewCell {

	private var assetId: String?

	private lazy var imageView: UIImageView = {
		let view = UIImageView()
		view.contentMode = .scaleAspectFill
		view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
		return view
	}()
    
    private lazy var effetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.5)
        view.layer.borderColor = #colorLiteral(red: 0.2588235294, green: 0.8666666667, blue: 1, alpha: 1)
        view.layer.borderWidth = 3
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(view, aboveSubview: imageView)
        return view
    }()

	override var isSelected: Bool {
		didSet {
            effetView.isHidden = !isSelected
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		layout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func update(with asset: PHAsset) {
        assetId = asset.localIdentifier
        imageView.fetchImageAsset(asset, frameSize: bounds.size) { [weak self] image, _ in
            if self?.assetId == asset.localIdentifier {
                self?.imageView.image = image
            }
        }
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
        
        NSLayoutConstraint.activate([
            effetView.topAnchor.constraint(equalTo: contentView.topAnchor),
            effetView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            effetView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            effetView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
	}
}
