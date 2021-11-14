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

    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [selectPhotoGuideView,
                                                  selectExerciseGuideView,
                                                  selectMoodGuideView])
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(view, aboveSubview: posterImageView)
        return view
    }()

    lazy var selectPhotoGuideView: SelectPhotoGuideView = {
        let view = SelectPhotoGuideView()
        return view
    }()

    lazy var selectExerciseGuideView: SelectExerciseGuideView = {
        let view = SelectExerciseGuideView()
        return view
    }()

    lazy var selectMoodGuideView: SelectMoodGuideView = {
        let view = SelectMoodGuideView()
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

    override func layoutSubviews() {
        stackView.arrangedSubviews.forEach {
            $0.addDashedBorder(with: #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1).withAlphaComponent(0.5), lineWidth: 1, cornerRadius: 0)
        }
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
        setStackViewLayout()
    }

    private func setPosterImageViewLayout() {
        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            posterImageView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    private func setStackViewLayout() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: Layout.stackViewSize.width),
            stackView.heightAnchor.constraint(equalToConstant: Layout.stackViewSize.height)
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
        static let stackViewSize = CGSize(width: 250, height: 492)
    }
}
