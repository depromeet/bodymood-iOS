import UIKit
import Photos
import Combine

class ExerciseListViewController: UIViewController {

    private lazy var collectionView: UICollectionView = { createCollectionView() }()
    private lazy var dataSource: DataSource = { createDataSource() }()

    private var bag = Set<AnyCancellable>()
    private let viewModel: ExerciseListViewModelType

    let itemList: [ExerciseItemModel]
    
    init(with itemList: [ExerciseItemModel], viewModel: ExerciseListViewModelType) {
        self.itemList = itemList
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
        updateList(with: itemList)
        style()
        layout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = []
    }
}

// MARK: - Bind
extension ExerciseListViewController {
    private func bind() {
        viewModel.shouldSelectItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] idx in
                self?.collectionView.selectItem(at: [0, idx], animated: true, scrollPosition: [])
            }.store(in: &bag)

        viewModel.shouldDeselectItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] idx in
                self?.collectionView.deselectItem(at: [0, idx], animated: true)
            }.store(in: &bag)
    }

    func updateList(with items: [ExerciseItemModel], animatingDifferences: Bool = true) {
        var snapshot = SnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - UICollectionViewDelegate
extension ExerciseListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        viewModel.itemTapped.send(indexPath.item)
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        viewModel.itemTapped.send(indexPath.item)
        return false
    }
}

// MARK: - Configure UI
extension ExerciseListViewController {

    private func style() {

    }

    private func layout() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: Create Views
    private func createCollectionView() -> UICollectionView {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.isDirectionalLockEnabled = true
        view.allowsMultipleSelection = true
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

        return DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }

    // MARK: Set Layouts
    var collectionViewLayout: UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(Layout.itemHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Layout.spacing
            section.contentInsets = .init(top: Layout.spacing,
                                          leading: Layout.leadingInset,
                                          bottom: Layout.bottomInset,
                                          trailing: 0)
            return section
        }
        return layout
    }
}

// MARK: - Definitions
extension ExerciseListViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ExerciseItemModel>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, ExerciseItemModel>
    typealias CellRegistration = UICollectionView.CellRegistration<ExerciseItemCell, ExerciseItemModel>

    enum Section {
        case main
    }

    enum Layout {
        static let itemHeight: CGFloat = 56
        static let spacing: CGFloat = 16
        static let leadingInset = CommonLayout.contentInset
        static let bottomInset: CGFloat = 100
    }
}
