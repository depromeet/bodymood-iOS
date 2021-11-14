import UIKit

class SelectMoodGuideView: UIButton {

    lazy var editButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .black.withAlphaComponent(0.2)
        view.layer.cornerRadius = Layout.btnSize.height / 2
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        addSubview(view)
        return view
    }()

    lazy var colorView: UIView = {
        let view = UIView()
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

    private func style() {
        setTitle("감정을 선택하세요", for: .normal)
        titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
        backgroundColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1).withAlphaComponent(0.4)
    }

    private func layout() {
        NSLayoutConstraint.activate([
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

        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 28),
            colorView.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    func update(with value: EmotionDataResponse) {
        setTitle(nil, for: .normal)
        editButton.isHidden = false
        backgroundColor = .clear

        stackView.removeAllArrangedSubviews()
        stackView.alignment = .center
        stackView.spacing = 8

        let englishTitleLabel = UILabel()
        englishTitleLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 24)
        englishTitleLabel.textColor = .white
        englishTitleLabel.text = value.englishTitle
        stackView.addArrangedSubview(englishTitleLabel)

        let koreanTitleLabel = UILabel()
        koreanTitleLabel.font = UIFont(name: "Pretendard-Bold", size: 12)
        koreanTitleLabel.textColor = .white
        koreanTitleLabel.text = value.koreanTitle
        stackView.addArrangedSubview(koreanTitleLabel)

        let startColor = hexStringToUIColor(hex: value.startColor!)
        colorView.backgroundColor = startColor
        colorView.layer.opacity = 0.8
        colorView.backgroundColor = .clear
        colorView.addDashedCircle(startColor: startColor)

        stackView.addArrangedSubview(colorView)
    }

    func gradientLocation(startColor: UIColor, endColor: UIColor) {
        let gradientLayerName = "gradientLayer"

        if let oldLayer = colorView.layer.sublayers?.filter({$0.name == gradientLayerName}).first {
            oldLayer.removeFromSuperlayer()
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = .init(x: 0, y: 0)
        gradientLayer.endPoint = .init(x: 1, y: 1)
        gradientLayer.frame = colorView.bounds
        gradientLayer.name = gradientLayerName
    }

    func hexStringToUIColor(hex: String) -> UIColor {
        var upperString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if upperString.hasPrefix("#") {
            upperString.remove(at: upperString.startIndex)
        }

        if upperString.count != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: upperString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    enum Layout {
        static let btnSize = CGSize(width: 40, height: 40)
        static let contentMinInset: CGFloat = 22
        static let topAnchor: CGFloat = 28
    }
}
