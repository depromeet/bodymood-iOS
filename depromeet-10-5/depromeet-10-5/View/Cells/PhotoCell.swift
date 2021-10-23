import UIKit
import Photos

class PhotoCell: UICollectionViewCell {

	private var assetId: String?

	private lazy var imageView: UIImageView = {
		let view = UIImageView()
		view.contentMode = .scaleAspectFill
		view.clipsToBounds = true
		view.layer.borderColor = #colorLiteral(red: 0, green: 0.4745098039, blue: 0.7411764706, alpha: 1)
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
		contentView.addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
}
