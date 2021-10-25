import UIKit
import Photos
import Combine

class PosterTemplateListViewController: UIViewController {

    private lazy var collectionView: UICollectionView = { createCollectionView() }()
    private lazy var dataSource: DataSource = { createDataSource() }()
    private lazy var selectButton: UIButton = { createSelectButton() }()
    private lazy var titleLabel: UILabel = { createTitleLabel() }()
    private lazy var pageIndicator: PageIndicator = { createPageIndicator() }()

    private var bag = Set<AnyCancellable>()
    private let viewModel: PosterTemplateListViewModelType

    init(viewModel: PosterTemplateListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        style()
        layout()
        bind()
    }
}

// MARK: - Bind
extension PosterTemplateListViewController {
    private func bind() {
        viewModel.templates
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] templates in
                self?.collectionView.allowsSelection = false
                self?.collectionView.allowsSelection = true
                self?.selectButton.isEnabled = false
                self?.pageIndicator.numberOfPages = templates.count
                self?.updateList(with: templates)
                self?.collectionView.scrollToItem(at: [0, 0], at: .centeredHorizontally, animated: true)
            }.store(in: &bag)

        viewModel.title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }.store(in: &bag)

        viewModel.selectBtnTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.selectButton.setTitle(title, for: .normal)
            }.store(in: &bag)

        viewModel.moveToPosterEdit
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                let detailVC = PosterDetailViewController(viewModel: PosterDetailViewModel(with: nil, mode: .editing, templateType: type))
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }.store(in: &bag)

        selectButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.selectBtnTapped.send(())
            }.store(in: &bag)

        navigationItem.leftBarButtonItem?.tap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }.store(in: &bag)
    }

    func updateList(with templates: [PosterTemplate], animatingDifferences: Bool = true) {
        var snapshot = SnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems(templates, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - UICollectionViewDelegate
extension PosterTemplateListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.templateSelected.send(indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard viewModel.templates.value[safe: indexPath.item]?.type != nil else { return false }

        let shouldSelect = !(collectionView.cellForItem(at: indexPath)?.isSelected ?? true)
        if !shouldSelect {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        selectButton.isEnabled = shouldSelect
        return shouldSelect
    }
}

// MARK: - Configure UI
extension PosterTemplateListViewController {

    private func style() {
        view.backgroundColor = .white

        let backIcon = ImageResource.leftArrow?.withTintColor(.black, renderingMode: .alwaysOriginal)
        navigationItem.leftBarButtonItem = .init(image: backIcon, style: .plain, target: nil, action: nil)
    }

    private func layout() {
        setTitleLabelLayout()
        setTemplateListViewLayout()
        setSelectButtonLayout()
        setPageIndicatorLayout()
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

    private func createSelectButton() -> UIButton {
        let view = UIButton()
        view.titleLabel?.font = .systemFont(ofSize: 16)
        view.layer.cornerRadius = Layout.btnHeight / 3
        view.clipsToBounds = true
        view.setBackgroundColor(.init(rgb: 0xAAAAAA), for: [.disabled])
        view.setBackgroundColor(.init(rgb: 0x1C1C1C), for: [.normal, .highlighted])
        view.setTitleColor(.white, for: .normal)
        view.setTitleColor(.init(rgb: 0xAAAAAA), for: .highlighted)
        view.isEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    private func createPageIndicator() -> PageIndicator {
        let view = PageIndicator()
        view.backgroundColor = .init(rgb: 0xAAAAAA).withAlphaComponent(0.3)
        view.bar.backgroundColor = .init(rgb: 0xAAAAAA)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    private func createCollectionView() -> UICollectionView {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout2)
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.isDirectionalLockEnabled = true
        view.isScrollEnabled = false
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    private func createDataSource() -> DataSource {
        let registration = CellRegistration { cell, _, item in
            cell.update(with: item.imageName)
        }

        return DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }

    private var collectionViewLayout2: UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] _, env in
            let containerSize = env.container.contentSize
            let templateSize = Layout.templateSize
            let ratio = templateSize.width / templateSize.height
            let itemMaxWidth = containerSize.height * ratio

            let itemWidth: CGFloat
            let itemHeight: CGFloat
            let sectionTopInset: CGFloat
            let horizontalInset = (containerSize.width - itemMaxWidth) / 2
            if horizontalInset > Layout.horizontalMinContentInset {
                itemWidth = itemMaxWidth
                itemHeight = containerSize.height
                sectionTopInset = 0
            } else {
                itemWidth = containerSize.width - Layout.horizontalMinContentInset * 2
                itemHeight = itemWidth / ratio
                sectionTopInset = (containerSize.height - itemHeight) / 2
            }

            let groupWidth = Layout.horizontalSpacing + itemWidth
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(groupWidth),
                                                  heightDimension: .absolute(itemHeight))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let half = Layout.horizontalSpacing / 2
            item.contentInsets = .init(top: 0, leading: half, bottom: 0, trailing: half)

            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(groupWidth),
                                                   heightDimension: .absolute(itemHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.contentInsets = .init(top: sectionTopInset, leading: 0, bottom: 0, trailing: 0)
            section.visibleItemsInvalidationHandler = { _, scrollOffset, layoutEnvironment in
                guard let self = self else { return }
                let contentWidth = layoutEnvironment.container.contentSize.width
                let offset = (contentWidth - groupWidth) / 2
                let point = scrollOffset.x + offset
                let totalWidth = CGFloat(self.viewModel.templates.value.count) * groupWidth
                self.pageIndicator.offsetX.send(point / totalWidth)
            }
            return section
        }
        return layout
    }

    // MARK: Set Layouts
    private func setTemplateListViewLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: Layout.contentInset),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setSelectButtonLayout() {
        NSLayoutConstraint.activate([
            selectButton.heightAnchor.constraint(equalToConstant: Layout.btnHeight),
            selectButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor,
                                              constant: Layout.btnTopOffset),
            selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: -Layout.contentInset),
            selectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                  constant: Layout.contentInset),
            selectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                   constant: -Layout.contentInset)
        ])
    }

    private func setTitleLabelLayout() {
        guard let superView = titleLabel.superview else { return  }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: superView.centerXAnchor)
        ])
    }

    private func setPageIndicatorLayout() {
        let guide = UILayoutGuide()
        view.addLayoutGuide(guide)
        NSLayoutConstraint.activate([
            pageIndicator.widthAnchor.constraint(equalToConstant: Layout.indicatorSize.width),
            pageIndicator.heightAnchor.constraint(equalToConstant: Layout.indicatorSize.height),
            pageIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guide.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            guide.bottomAnchor.constraint(equalTo: selectButton.topAnchor),
            pageIndicator.centerYAnchor.constraint(equalTo: guide.centerYAnchor)
        ])
    }
}

// MARK: - Definitions
extension PosterTemplateListViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, PosterTemplate>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, PosterTemplate>
    typealias CellRegistration = UICollectionView.CellRegistration<PosterTemplateCell, PosterTemplate>

    enum Section {
        case main
    }

    enum Layout {
        static let horizontalSpacing: CGFloat = 16
        static let horizontalMinContentInset: CGFloat = 32.5

        static let btnTopOffset: CGFloat = 88
        static let btnHeight: CGFloat = 56
        static let contentInset = CommonLayout.contentInset

        static let indicationTopOffset: CGFloat = 14
        static let indicationBottomOffset: CGFloat = 69
        static let indicatorSize = CGSize(width: 200, height: 5)

        static let templateSize: CGSize = PosterModel.defaultSize
    }
}
