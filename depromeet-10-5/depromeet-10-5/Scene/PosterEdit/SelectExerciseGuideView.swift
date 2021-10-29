import UIKit

class SelectExerciseGuideView: UIButton {

    lazy var editButton: UIButton = {
        let view = UIButton()
        let image = ImageResource.addPhoteFromAlbum
        view.setImage(image?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        view.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        view.backgroundColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1).withAlphaComponent(0.3)
        view.isUserInteractionEnabled = false
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
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
    
    func update(with list: [String]) {
        setTitle(nil, for: .normal)
        editButton.isHidden = false
        backgroundColor = .clear
        stackView.removeAllArrangedSubviews()
        list.forEach { text in
            let label = UILabel()
            label.font = .boldSystemFont(ofSize: 18)
            label.textColor = .white
            label.text = text
            stackView.addArrangedSubview(label)
        }
    }

    private func style() {
        setTitle("운동을 선택하세요", for: .normal)
        backgroundColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1).withAlphaComponent(0.4)
        titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            editButton.topAnchor.constraint(equalTo: topAnchor,
                                            constant: Layout.contentMinInset),
            editButton.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                 constant: -Layout.contentMinInset),
            editButton.widthAnchor.constraint(equalToConstant: Layout.btnSize.width),
            editButton.heightAnchor.constraint(equalToConstant: Layout.btnSize.height)
        ])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                 constant: Layout.contentMinInset),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                 constant: -Layout.contentMinInset),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                              constant: -Layout.contentMinInset)
        ])
    }

    enum Layout {
        static let btnSize = CGSize(width: 40, height: 40)
        static let contentMinInset: CGFloat = 15
    }
}
