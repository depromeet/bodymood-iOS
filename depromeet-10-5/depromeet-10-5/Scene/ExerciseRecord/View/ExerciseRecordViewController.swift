import UIKit
import Combine

class ExerciseRecordViewController: UIViewController {

    private lazy var menuBar: UICollectionView = { createMenuBarView() }()
    private lazy var dataSource: DataSource = { createDataSource() }()
    private lazy var pageIndicator: PageIndicator = { createPageIndicator() }()
    private lazy var secondDepthCategoryVC: UIPageViewController = { createSecondDepthCategoryVC() }()
    private lazy var bottomButton: DefaultBottomButton = { createBottomButtonView() }()

    private let viewModel: ExerciseRecordViewModelType
    private var bag = Set<AnyCancellable>()

    init(with viewModel: ExerciseRecordViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        bind()
    }

    private func bind() {
        viewModel.firstDepthCategories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] list in
                self?.updateMenu(with: list)
                self?.pageIndicator.numberOfPages = list.count
            }.store(in: &bag)

        viewModel.currentIdxOfFirstDepth
            .receive(on: DispatchQueue.main)
            .sink { [weak self] idx in
                guard let self = self else { return }
                self.pageIndicator.moveToPage.send(idx)
                self.menuBar.selectItem(at: [0, idx], animated: true, scrollPosition: .left)
            }.store(in: &bag)

        viewModel.bgColorHexPair
            .receive(on: DispatchQueue.main)
            .sink { [weak self] first, second in
                self?.view.addDiagonalGradiant(startColor: UIColor(rgb: first), endColor: UIColor(rgb: second))
            }.store(in: &bag)

        viewModel.canShowButton
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canShow in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.2) {
                    let transform = CGAffineTransform(translationX: 0, y: self.bottomButton.frame.height)
                    self.bottomButton.transform = canShow ? .identity : transform
                }
            }.store(in: &bag)

        viewModel.canEnableButton
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canEnable in
                self?.bottomButton.isEnabled = canEnable
            }.store(in: &bag)

        viewModel.buttonTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.bottomButton.label.text = title
            }.store(in: &bag)

        bottomButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.selectBtnTapped.send(())
            }.store(in: &bag)

        navigationItem.leftBarButtonItem?.tap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }.store(in: &bag)
    }
    
    private func updateMenu(with items: [ExerciseItemModel], animatingDifferences: Bool = true) {
        var snapshot = SnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension ExerciseRecordViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.currentIdxOfFirstDepth.send(indexPath.item)
    }
}

// MARK: - Configure UI
extension ExerciseRecordViewController {
    private func style() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        let colorPair = self.viewModel.bgColorHexPair.value
        let blendedColor = UIColor(rgb: colorPair.0).add(UIColor(rgb: colorPair.1))
        let backIcon = ImageResource.leftArrow?.withTintColor(blendedColor.isDarkColor ? .white : .black,
                                                              renderingMode: .alwaysOriginal)
        navigationItem.leftBarButtonItem = .init(image: backIcon, style: .plain, target: nil, action: nil)
    }

    private func layout() {
        setMenuBarLayout()
        setPageIndicatorLayout()
        setSecondDepthCategoryViewLayout()
        setBottomButtonLayout()
    }

    // MARK: Create Views
    private func createMenuBarView() -> UICollectionView {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        self.view.addSubview(view)
        return view
    }

    private func createDataSource() -> DataSource {
        let registration = CellRegistration { [weak self] cell, _, item in
            guard let self = self else { return }
            let colorPair = self.viewModel.bgColorHexPair.value
            let blendedColor = UIColor(rgb: colorPair.0).add(UIColor(rgb: colorPair.1))
            cell.update(with: item, parentBgColor: blendedColor)
        }

        return DataSource(collectionView: menuBar) { collectionView, indexPath, item -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }

    private func createPageIndicator() -> PageIndicator {
        let view = PageIndicator()
        view.backgroundColor = .init(rgb: 0xAAAAAA).withAlphaComponent(0.3)
        view.bar.backgroundColor = .init(rgb: 0xAAAAAA)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    private func createSecondDepthCategoryVC() -> UIPageViewController {
        let pageVC = ExerciseCategoryPageViewController(with: viewModel)
        addChild(pageVC)
        self.view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        return pageVC
    }

    private func createBottomButtonView() -> DefaultBottomButton {
        let view = DefaultBottomButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEnabled = false
        self.view.addSubview(view)
        return view
    }

    // MARK: Set Layout
    var collectionViewLayout: UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(Layout.itemMinWidth),
                                                  heightDimension: .estimated(Layout.itemHeight))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(Layout.itemMinWidth),
                                                   heightDimension: .estimated(Layout.itemHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Layout.spacing
            section.orthogonalScrollingBehavior = .continuous
            return section
        }
        return layout
    }

    private func setBottomButtonLayout() {
        NSLayoutConstraint.activate([
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setMenuBarLayout() {
        NSLayoutConstraint.activate([
            menuBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                         constant: Layout.menuBarTopOffset),
            menuBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                             constant: Layout.leadingInset),
            menuBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            menuBar.heightAnchor.constraint(equalToConstant: Layout.itemHeight)
        ])
    }

    private func setPageIndicatorLayout() {
        NSLayoutConstraint.activate([
            pageIndicator.topAnchor.constraint(equalTo: menuBar.bottomAnchor,
                                               constant: Layout.indicatorTopOffset),
            pageIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: Layout.leadingInset),
            pageIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageIndicator.heightAnchor.constraint(equalToConstant: Layout.indicatorHeight)
        ])
    }

    private func setSecondDepthCategoryViewLayout() {
        if let subView = secondDepthCategoryVC.view {
            subView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                subView.topAnchor.constraint(equalTo: pageIndicator.bottomAnchor,
                                             constant: Layout.listViewTopOffset),
                subView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                subView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                subView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    }
}

// MARK: - Definitions
extension ExerciseRecordViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ExerciseItemModel>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, ExerciseItemModel>
    typealias CellRegistration = UICollectionView.CellRegistration<FirstDepthCategoryCell, ExerciseItemModel>

    enum Section {
        case main
    }

    enum Layout {
        static let leadingInset = CommonLayout.contentInset
        static let indicatorTopOffset: CGFloat = 10
        static let listViewTopOffset: CGFloat = 40
        static let indicatorHeight: CGFloat = 1
        static let bottomInset: CGFloat = 100

        static let menuBarTopOffset: CGFloat = 18
        static let itemHeight: CGFloat = 60
        static let itemMinWidth: CGFloat = 44
        static let spacing: CGFloat = 30
    }
}

// TODO: 테스트 용 코드, 추후 제거할 것
func presentExerciseRecordVC(on viewController: UIViewController) {
    let vc = ExerciseRecordViewController(with: ExerciseRecordViewModel(useCase: ExerciseRecordUseCase(), bgColorHexPair: ((0xAA2900, 0x221E47))))
    let nav = UINavigationController(rootViewController: vc)
    nav.overrideUserInterfaceStyle = .light
    nav.modalPresentationStyle = .fullScreen
    viewController.present(nav, animated: true, completion: nil)
}
