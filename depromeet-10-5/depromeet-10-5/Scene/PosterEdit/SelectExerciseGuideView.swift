import UIKit

class SelectExerciseGuideView: UIButton {

    lazy var editButton: UIButton = {
        let view = UIButton()
        let image = ImageResource.addPhoteFromCamera
        view.setImage(image?.withTintColor(.white, renderingMode: .alwaysTemplate), for: .normal)
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
        setTitle("Put your exercises", for: .normal)
        backgroundColor = .green
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
        static let size = CGSize(width: 247, height: 148)
        static let btnSize = CGSize(width: 40, height: 40)
    }
}
