import UIKit
import Combine

class PosterEditViewController: UIViewController {
    private lazy var scrollView: UIScrollView = { createScrollView() }()
    private lazy var titleLabel: UILabel = { createTitleLabel() }()
    private lazy var bottomButton: DefaultBottomButton = { createBottomButtonView() }()
    private lazy var posterEditGuideView: PosterEditGuideView = { createPosterEditGuideView() }()

    private let viewModel: PosterEditViewModelType
    private var bag = Set<AnyCancellable>()

    init(viewModel: PosterEditViewModelType) {
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
}

// MARK: - Bind ViewModel
extension PosterEditViewController {
    private func bind() {

        viewModel.title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }.store(in: &bag)

        bottomButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.completeBtnTapped.send()
            }.store(in: &bag)

        navigationItem.leftBarButtonItem?.tap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }.store(in: &bag)

        viewModel.moveToAlbum
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                let albumVM = AlbumViewModel(useCase: AlbumUseCase())
                let albumVC = AlbumViewController(viewModel: albumVM)
                self?.navigationController?.pushViewController(albumVC, animated: true)
            }.store(in: &bag)
        
        viewModel.moveToCamera
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                
            }.store(in: &bag)

        viewModel.moveToExerciseCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                let categoryVM = ExerciseRecordViewModel(useCase: ExerciseRecordUseCase(),
                                                         bgColorHexPair: ((0xAA2900, 0x221E47)))
                let categoryVC = ExerciseRecordViewController(with: categoryVM)
                self?.navigationController?.pushViewController(categoryVC, animated: true)
            }.store(in: &bag)

        viewModel.moveToMoodList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                
            }.store(in: &bag)
    }
}

// MARK: - Definitions
extension PosterEditViewController {
    private enum Layout {
        static let horizontalInset = CommonLayout.horizontalInset
        static let btnHeight: CGFloat = 56
        static let contentInset: CGFloat = 24
        static let contentBottomInset: CGFloat = 58
        static let posterSize = PosterModel.defaultSize
    }
}

// MARK: - Configure UI
extension PosterEditViewController {

    private func style() {
        view.backgroundColor = .white

        let backIcon = ImageResource.leftArrow?.withTintColor(.black, renderingMode: .alwaysOriginal)
        navigationItem.leftBarButtonItem = .init(image: backIcon, style: .plain, target: nil, action: nil)
    }

    private func layout() {
        setTitleLabelLayout()
        setBottomButtonLayout()
        setScrollViewLayout()
        setPosterEditGuideViewLayout()
    }

    // MARK: Create Views
    private func createTitleLabel() -> UILabel {
        let view = UILabel()
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = view
        return view
    }

    private func createBottomButtonView() -> DefaultBottomButton {
        let view = DefaultBottomButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    private func createScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    private func createPosterEditGuideView() -> PosterEditGuideView {
        let view = PosterEditGuideView(with: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(view)
        return view
    }

    // MARK: Set Layouts
    private func setTitleLabelLayout() {
        guard let superView = titleLabel.superview else { return  }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: superView.centerXAnchor)
        ])
    }
    
    private func setScrollViewLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: Layout.contentInset),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Layout.contentInset),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -Layout.contentInset)
        ])
    }
    
    private func setPosterEditGuideViewLayout() {
        let ratio = Layout.posterSize.width / Layout.posterSize.height
        NSLayoutConstraint.activate([
            posterEditGuideView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            posterEditGuideView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            posterEditGuideView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            posterEditGuideView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            posterEditGuideView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            posterEditGuideView.widthAnchor.constraint(equalTo: posterEditGuideView.heightAnchor,
                                                       multiplier: ratio)
        ])
    }
    
    private func setBottomButtonLayout() {
        NSLayoutConstraint.activate([
            bottomButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor,
                                              constant: Layout.contentInset),
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}


