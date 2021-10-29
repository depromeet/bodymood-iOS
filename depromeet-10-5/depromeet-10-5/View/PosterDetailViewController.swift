import UIKit
import Combine

class PosterDetailViewController: UIViewController {
    private lazy var bottomButtonContainer: UIStackView = { createHorizontalStackView() }()
    private lazy var posterImageView: PosterView = { createPosterImageView() }()
    private lazy var shareButton: UIButton = { createBottomButton() }()
    private lazy var completeButton: UIButton = { createBottomButton() }()
    private lazy var titleLabel: UILabel = { createTitleLabel() }()

    private lazy var posterGuide = { createPosterLayoutGuide() }()
    private var posterWidthConstraint: NSLayoutConstraint?
    private var posterHeightConstraint: NSLayoutConstraint?

    private let viewModel: PosterDetailViewModelType
    private var bag = Set<AnyCancellable>()

    init(viewModel: PosterDetailViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        style()
        layout()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updatePosterLayout()
    }
}

// MARK: - Bind ViewModel
extension PosterDetailViewController {
    private func bind() {
        viewModel.contentMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mode in
                self?.configure(with: mode)
            }.store(in: &bag)

        viewModel.poster
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] asset in
                self?.posterImageView.imageView.fetchImageAsset(asset) { image, _ in
                    self?.posterImageView.imageView.image = image
                }
            }.store(in: &bag)

        viewModel.makePoster
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image, exercises, emotion in
                self?.posterImageView.makePoster(image, exercises, emotion)

                let value1 = Int(UInt32(emotion.startColor?.dropFirst() ?? "", radix: 16) ?? 0)
                let value2 = Int(UInt32(emotion.endColor?.dropFirst() ?? "", radix: 16) ?? 0)
                self?.view.addDiagonalGradiant(startColor: UIColor(rgb: value1).withAlphaComponent(0.2),
                                              endColor: UIColor(rgb: value2).withAlphaComponent(0.2))
            }.store(in: &bag)

        viewModel.title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }.store(in: &bag)

        viewModel.shareBtnTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.shareButton.setTitle(title, for: .normal)
            }.store(in: &bag)

        shareButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.shareBtnTapped.send()
            }.store(in: &bag)

        viewModel.showShareBottomSheet
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let image = self?.posterImageView.imageView.image else { return }
                let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                self?.present(activityVC, animated: true, completion: nil)
            }.store(in: &bag)

        navigationItem.leftBarButtonItem?.tap
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }.store(in: &bag)
    }

    private func configure(with mode: PosterDetailContentMode) {
        bottomButtonContainer.removeAllArrangedSubviews()
        bottomButtonContainer.addArrangedSubview(shareButton)
    }
}

// MARK: - Definitions
extension PosterDetailViewController {
    private enum Layout {
        static let horizontalInset = CommonLayout.horizontalInset
        static let btnHeight: CGFloat = 56
        static let contentInset: CGFloat = 24
        static let contentBottomInset: CGFloat = 58
    }
}

// MARK: - Configure UI
extension PosterDetailViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    private func style() {
        view.backgroundColor = .white

        let backIcon = ImageResource.leftArrow?.withTintColor(.black, renderingMode: .alwaysOriginal)
        navigationItem.leftBarButtonItem = .init(image: backIcon, style: .plain, target: nil, action: nil)
    }

    private func layout() {
        setTitleLabelLayout()
        setPosterLayout()
        setButtonContainerLayout()
    }

    // MARK: Create Views
    private func createTitleLabel() -> UILabel {
        let view = UILabel()
        view.textAlignment = .center
        view.font = UIFont(name: "Pretended-Regular", size: 16)
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = view
        return view
    }

    private func createPosterLayoutGuide() -> UILayoutGuide {
        let guide = UILayoutGuide()
        view.addLayoutGuide(guide)
        return guide
    }

    private func createPosterImageView() -> PosterView {
        let view = PosterView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    private func createBottomButton() -> UIButton {
        let view = UIButton()
        view.titleLabel?.font = UIFont(name: "Pretended-Regular", size: 16)
        view.layer.cornerRadius = Layout.btnHeight / 3
        view.clipsToBounds = true
        view.setBackgroundColor(.init(rgb: 0xAAAAAA), for: [.disabled])
        view.setBackgroundColor(.init(rgb: 0x1C1C1C), for: [.normal, .highlighted])
        view.setTitleColor(.white, for: .normal)
        view.setTitleColor(.init(rgb: 0xAAAAAA), for: .highlighted)
        view.isEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createHorizontalStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    private func createPosterEditGuideView() -> PosterEditGuideView {
        let view = PosterEditGuideView(with: PosterEditViewModel())
        view.isHidden = true
        view.backgroundColor = UIColor(rgb: 0xF7F7F7)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(view, aboveSubview: posterImageView)
        return view
    }

    // MARK: Set Layouts
    private func setTitleLabelLayout() {
        guard let superView = titleLabel.superview else { return  }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: superView.centerXAnchor)
        ])
    }

    private func setPosterLayout() {
        let size = PosterModel.defaultSize
        let ratio = size.height / size.width

        NSLayoutConstraint.activate([
            posterGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                       constant: Layout.contentInset),
            posterGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                           constant: Layout.contentInset),
            posterGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                            constant: -Layout.contentInset),
            posterGuide.bottomAnchor.constraint(equalTo: bottomButtonContainer.topAnchor,
                                          constant: -Layout.contentBottomInset),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: ratio),
            posterImageView.centerXAnchor.constraint(equalTo: posterGuide.centerXAnchor),
            posterImageView.centerYAnchor.constraint(equalTo: posterGuide.centerYAnchor)
        ])

        posterWidthConstraint = posterImageView.widthAnchor.constraint(equalTo: posterGuide.widthAnchor)
        posterHeightConstraint = posterImageView.heightAnchor.constraint(equalTo: posterGuide.heightAnchor)
    }

    private func setButtonContainerLayout() {
        NSLayoutConstraint.activate([
            bottomButtonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                     constant: Layout.contentInset),
            bottomButtonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                      constant: -Layout.contentInset),
            bottomButtonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -Layout.contentInset),
            bottomButtonContainer.heightAnchor.constraint(equalToConstant: Layout.btnHeight)
        ])
    }

    private func updatePosterLayout() {
        let posterSize = PosterModel.defaultSize
        let containerSize = posterGuide.layoutFrame.size
        let cond = posterSize.width / posterSize.height > containerSize.width / containerSize.height
        posterWidthConstraint?.isActive = cond
        posterHeightConstraint?.isActive = !cond
    }
}
