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
        setTitle("Choose your mood", for: .normal)
        backgroundColor = .blue
    }
    
    private func layout() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: Layout.size.width),
            heightAnchor.constraint(equalToConstant: Layout.size.height)
        ])

        NSLayoutConstraint.activate([
            editButton.widthAnchor.constraint(equalToConstant: Layout.btnSize.width),
            editButton.heightAnchor.constraint(equalToConstant: Layout.btnSize.height),
        ])
    }
    
    enum Layout {
        static let size = CGSize(width: 207, height: 86)
        static let btnSize = CGSize(width: 40, height: 40)
    }
}
