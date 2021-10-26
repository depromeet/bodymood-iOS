import UIKit

class SelectPhotoGuideView: UIView {

    lazy var cameraButton: UIButton = { createButton(with: ImageResource.addPhoteFromCamera) }()
    lazy var albumButton: UIButton  = { createButton(with: ImageResource.addPhoteFromAlbum) }()
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = "Take a Photo"
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()

    lazy var buttonContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [cameraButton, albumButton])
        view.distribution = .equalSpacing
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()
    
    private func createButton(with image: UIImage?) -> UIButton {
        let view = UIButton()
        view.setImage(image?.withTintColor(.white, renderingMode: .alwaysTemplate), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    init() {
        super.init(frame: .zero)

        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func style() {
        backgroundColor = .yellow
    }
    
    private func layout() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: Layout.size.width),
            heightAnchor.constraint(equalToConstant: Layout.size.height)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            buttonContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonContainer.heightAnchor.constraint(equalToConstant: Layout.btnSize.height)
        ])

        NSLayoutConstraint.activate([
            cameraButton.widthAnchor.constraint(equalToConstant: Layout.btnSize.width),
            cameraButton.heightAnchor.constraint(equalToConstant: Layout.btnSize.height),
            albumButton.widthAnchor.constraint(equalToConstant: Layout.btnSize.width),
            albumButton.heightAnchor.constraint(equalToConstant: Layout.btnSize.height)
        ])
    }
    
    enum Layout {
        static let size = CGSize(width: 279, height: 138)
        static let btnSize = CGSize(width: 40, height: 40)
    }
}
