import UIKit
import Combine

class PosterEditViewController: UIViewController {
    private lazy var checkBoxContainer: UIStackView = { createCheckBoxContainer() }()
    private lazy var scrollView: UIScrollView = { createScrollView() }()
    private lazy var titleLabel: UILabel = { createTitleLabel() }()
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

        navigationItem.leftBarButtonItem?.tap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }.store(in: &bag)
        
        navigationItem.rightBarButtonItem?.tap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.completeBtnTapped.send()
                self.posterEditGuideView.selectPhotoGuideView.isHidden = true
                let image = self.posterEditGuideView.toImage(with: PosterModel.defaultSize)
//                UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                    self.present(activityVC, animated: true, completion: nil)
                }
            }.store(in: &bag)

        viewModel.moveToAlbum
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                let albumVM = AlbumViewModel(useCase: AlbumUseCase(),
                                             resultReciever: self.viewModel.photoSelectedFromAlbum)
                let albumVC = AlbumViewController(viewModel: albumVM)
                self.navigationController?.pushViewController(albumVC, animated: true)
            }.store(in: &bag)

        viewModel.moveToCamera
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in

            }.store(in: &bag)

        viewModel.moveToExerciseCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                let categoryVM = ExerciseRecordViewModel(useCase: ExerciseRecordUseCase(),
                                                         bgColorHexPair: ((0xAA2900, 0x221E47)),
                                                         resultReciever: self.viewModel.exerciseSelected)
                let categoryVC = ExerciseRecordViewController(with: categoryVM)
                self.navigationController?.pushViewController(categoryVC, animated: true)
            }.store(in: &bag)

        viewModel.moveToMoodList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in

            }.store(in: &bag)

        viewModel.photoSelectedFromAlbum
            .receive(on: DispatchQueue.main)
            .sink { [weak self] asset in
                guard let self = self else { return }
                let imageView = self.posterEditGuideView.posterImageView
                imageView.fetchImageAsset(asset, frameSize: imageView.bounds.size) { image, _ in
                    imageView.image = image
                    self.posterEditGuideView.selectPhotoGuideView.backgroundColor = .clear
                    self.updateCheckBox(index: 0)
                }
            }.store(in: &bag)

        viewModel.exerciseSelected
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] list in
                guard let self = self else { return }
                self.posterEditGuideView.selectExerciseGuideView.update(with: list.map { $0.english })
                self.updateCheckBox(index: 1)
            }.store(in: &bag)
    }
    
    private func updateCheckBox(index: Int) {
        (checkBoxContainer.arrangedSubviews[safe: index] as? CheckBoxView)?.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
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
        let item = UIBarButtonItem(title: "완료", style: .plain, target: nil, action: nil)
        item.tintColor = .black
        navigationItem.rightBarButtonItem = item
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    private func layout() {
        setCheckBoxLayout()
        setTitleLabelLayout()
        setScrollViewLayout()
        setPosterEditGuideViewLayout()
    }

    // MARK: Create Views
    private func createCheckBoxContainer() -> UIStackView {
        let view = UIStackView()
        ["사진", "운동", "감정"].forEach { view.addArrangedSubview(createCheckBoxView(with: $0)) }
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    private func createCheckBoxView(with text: String) -> CheckBoxView {
        let view = CheckBoxView()
        view.text = text
        view.tintColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
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

    private func setCheckBoxLayout() {
        NSLayoutConstraint.activate([
            checkBoxContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: Layout.contentInset),
            checkBoxContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setScrollViewLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: checkBoxContainer.bottomAnchor,
                                            constant: Layout.contentInset),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Layout.contentInset),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -Layout.contentInset),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
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
}
