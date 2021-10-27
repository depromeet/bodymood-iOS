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
        backgroundColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1).withAlphaComponent(0.4)
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            editButton.widthAnchor.constraint(equalToConstant: Layout.btnSize.width),
            editButton.heightAnchor.constraint(equalToConstant: Layout.btnSize.height),
        ])
    }
    
    enum Layout {
        static let btnSize = CGSize(width: 40, height: 40)
    }
}
