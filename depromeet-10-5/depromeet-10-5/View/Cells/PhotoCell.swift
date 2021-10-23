import UIKit
import Photos

class PhotoCell: UICollectionViewCell {

	private var requestID: PHImageRequestID?

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
		requestID = imageView.fetchImageAsset(asset, frameSize: bounds.size)
	}

	override func prepareForReuse() {
		if let requestID = requestID {
			PHImageManager.default().cancelImageRequest(requestID)
		}
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
