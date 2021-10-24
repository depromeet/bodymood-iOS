import UIKit
import Combine

class PosterDetailViewController: UIViewController {
    private lazy var scrollView: UIScrollView = { createScrollView() }()
    private lazy var stackView: UIStackView = { createStackView() }()
    private lazy var posterImageView: UIImageView = { createPosterImageView() }()
    private lazy var shareButton: UIButton = { createShareButton() }()
    private lazy var titleLabel: UILabel = { createTitleLabel() }()

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
        style()
        layout()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: Bind ViewModel
    private func bind() {
        viewModel.poster
            .receive(on: DispatchQueue.main)
            .sink { [weak self] asset in
                self?.posterImageView.fetchImageAsset(asset) { image, _ in
                    self?.posterImageView.image = image
                }
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
                guard let image = self?.posterImageView.image else { return }
                let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                self?.present(activityVC, animated: true, completion: nil)
            }.store(in: &bag)

        navigationItem.leftBarButtonItem?.tap
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }.store(in: &bag)
    }

}

// MARK: - Definitions
extension PosterDetailViewController {
    private enum Layout {
        static let horizontalInset = CommonLayout.horizontalInset
        static let shareBtnHeight: CGFloat = 56
        static let contentInset: CGFloat = 24
    }
}

// MARK: - Configure UI
extension PosterDetailViewController {

    private func style() {
        view.backgroundColor = .white

        let backIcon = ImageResource.leftArrow?.withTintColor(.black, renderingMode: .alwaysOriginal)
        navigationItem.leftBarButtonItem = .init(image: backIcon, style: .plain, target: nil, action: nil)
    }

    private func layout() {
        setTitleLabelLayout()
        setContentViewLayout()
        setPosterImageViewLayout()
        setShareButtonLayout()
    }

    // MARK: Create Views
    private func createScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    private func createStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.isLayoutMarginsRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        let inset = Layout.contentInset
        view.layoutMargins = UIEdgeInsets(top: inset,
                                          left: inset,
                                          bottom: inset * 2 + Layout.shareBtnHeight,
                                          right: inset)
        scrollView.addSubview(view)
        return view
    }

    private func createTitleLabel() -> UILabel {
        let view = UILabel()
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = view
        return view
    }

    private func createPosterImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(view)
        return view
    }

    private func createShareButton() -> UIButton {
        let view = UIButton()
        view.titleLabel?.font = .systemFont(ofSize: 16)
        view.layer.cornerRadius = Layout.shareBtnHeight / 3
        view.clipsToBounds = true
        view.backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        view.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        view.setTitleColor(#colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1), for: .highlighted)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    // MARK: Set Layouts
    private func setTitleLabelLayout() {
        guard let superView = titleLabel.superview else { return  }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: superView.centerXAnchor)
        ])
    }

    private func setContentViewLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])
    }

    private func setPosterImageViewLayout() {
        let size = PosterModel.defaultSize
        let ratio = size.height / size.width
        NSLayoutConstraint.activate([
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: ratio)
        ])
    }

    private func setShareButtonLayout() {
        NSLayoutConstraint.activate([
            shareButton.heightAnchor.constraint(equalToConstant: Layout.shareBtnHeight),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -Layout.contentInset),
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                 constant: Layout.contentInset),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -Layout.contentInset)
        ])
    }
}
