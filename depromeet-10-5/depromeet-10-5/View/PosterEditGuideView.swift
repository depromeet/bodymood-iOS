import UIKit

class PosterEditGuideView: UIView {

    let selectPhotoGuideView = SelectPhotoGuideView()
    let selectExerciseGuideView = SelectExerciseGuideView()
    let selectMoodGuideView = SelectMoodGuideView()

    lazy var guideContentView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [selectPhotoGuideView, selectExerciseGuideView, selectMoodGuideView])
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        insertSubview(view, aboveSubview: posterImageView)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var posterImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()
    
    enum Style {
        static let defaultButtonBgColor = UIColor(argb: 0xbbbbbb).withAlphaComponent(0.7)
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
        backgroundColor = UIColor(rgb: 0xF7F7F7)
    }

    enum Layout {
        
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            posterImageView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            guideContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            guideContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            guideContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            guideContentView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
    }
}

extension UIView {
    func addDashedBorder() {
        let color = UIColor.red.cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}
