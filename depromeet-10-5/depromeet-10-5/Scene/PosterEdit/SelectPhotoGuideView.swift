import UIKit

class SelectPhotoGuideView: UIView {

    lazy var cameraButton: UIButton = { createButton(with: ImageResource.addPhoteFromCamera) }()
    lazy var albumButton: UIButton  = { createButton(with: ImageResource.addPhoteFromAlbum) }()
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = "사진을 선택하세요"
        view.textAlignment = .center
        view.font = UIFont(name: "Pretendard-Bold", size: 16)
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()
    
    private func createButton(with image: UIImage?) -> UIButton {
        let view = UIButton()
        view.backgroundColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1).withAlphaComponent(0.3)
        view.setImage(image?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
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
        backgroundColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1).withAlphaComponent(0.4)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor,
                                            constant: Layout.titleLabelTopInset),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        let guide = UILayoutGuide()
        addLayoutGuide(guide)

        NSLayoutConstraint.activate([
            guide.centerXAnchor.constraint(equalTo: centerXAnchor),
            guide.widthAnchor.constraint(equalToConstant: 32),
            guide.heightAnchor.constraint(equalToConstant: 16),
            guide.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            cameraButton.trailingAnchor.constraint(equalTo: guide.leadingAnchor),
            cameraButton.topAnchor.constraint(equalTo: guide.bottomAnchor),
            albumButton.leadingAnchor.constraint(equalTo: guide.trailingAnchor),
            albumButton.topAnchor.constraint(equalTo: guide.bottomAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: Layout.btnSize.width),
            cameraButton.heightAnchor.constraint(equalToConstant: Layout.btnSize.height),
            albumButton.widthAnchor.constraint(equalToConstant: Layout.btnSize.width),
            albumButton.heightAnchor.constraint(equalToConstant: Layout.btnSize.height)
        ])
    }

    enum Layout {
        static let titleLabelTopInset: CGFloat = 36
        static let btnSize = CGSize(width: 40, height: 40)
    }
}
