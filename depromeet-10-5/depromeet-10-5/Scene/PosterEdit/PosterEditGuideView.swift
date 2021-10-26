import UIKit
import Combine

class PosterEditGuideView: UIView {
    lazy var posterImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()

    lazy var layoutGuide: UILayoutGuide = {
        let guide = UILayoutGuide()
        addLayoutGuide(guide)
        return guide
    }()

    lazy var selectPhotoGuideView: SelectPhotoGuideView = {
        let view = SelectPhotoGuideView()
        view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(view, aboveSubview: posterImageView)
        return view
    }()

    lazy var selectExerciseGuideView: SelectExerciseGuideView = {
        let view = SelectExerciseGuideView()
        view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(view, aboveSubview: posterImageView)
        return view
    }()

    lazy var selectMoodGuideView: SelectMoodGuideView = {
        let view = SelectMoodGuideView()
        view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(view, aboveSubview: posterImageView)
        return view
    }()

    private let viewModel: PosterEditGuideViewModelType
    private var bag = Set<AnyCancellable>()

    init(with viewModel: PosterEditGuideViewModelType) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        style()
        layout()
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bind() {
        selectPhotoGuideView.cameraButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.cameraBtnTapped.send()
            }.store(in: &bag)

        selectPhotoGuideView.albumButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.albumBtnTapped.send()
            }.store(in: &bag)

        selectExerciseGuideView.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.selectExerciseBtnTapped.send()
            }.store(in: &bag)

        selectMoodGuideView.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.selectMoodBtnTapped.send()
            }.store(in: &bag)
    }
}

// MARK: - Configure UI
extension PosterEditGuideView {
    private func style() {
        backgroundColor = UIColor(rgb: 0xF7F7F7)
    }

    private func layout() {
        setPosterImageViewLayout()
        setLayoutGuideLayout()
        setSelectPhotoGuideViewLayout()
        setSelectExerciseGuideViewLayout()
        setSelectMoodGuideViewLayout()
    }

    private func setPosterImageViewLayout() {
        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            posterImageView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }

    private func setLayoutGuideLayout() {
        NSLayoutConstraint.activate([
            layoutGuide.widthAnchor.constraint(equalToConstant: Layout.guideViewSize.width),
            layoutGuide.heightAnchor.constraint(equalToConstant: Layout.guideViewSize.height),
            layoutGuide.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor),
            layoutGuide.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor)
        ])
    }

    private func setSelectPhotoGuideViewLayout() {
        NSLayoutConstraint.activate([
            selectPhotoGuideView.topAnchor.constraint(equalTo: layoutGuide.topAnchor,
                                                      constant: 62),
            selectPhotoGuideView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor)
        ])
    }

    private func setSelectExerciseGuideViewLayout() {
        NSLayoutConstraint.activate([
            selectExerciseGuideView.topAnchor.constraint(equalTo: selectPhotoGuideView.bottomAnchor,
                                                         constant: 47),
            selectExerciseGuideView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor)
        ])
    }

    private func setSelectMoodGuideViewLayout() {
        NSLayoutConstraint.activate([
            selectMoodGuideView.topAnchor.constraint(equalTo: selectExerciseGuideView.bottomAnchor,
                                                     constant: 51),
            selectMoodGuideView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            selectMoodGuideView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -48)
        ])
    }
}

// MARK: - Definitions
extension PosterEditGuideView {
    enum Style {
        static let defaultButtonBgColor = UIColor(argb: 0xbbbbbb).withAlphaComponent(0.7)
    }

    enum Layout {
        static let spacing: CGFloat = 50
        static let guideViewSize = CGSize(width: 327, height: 580)
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
