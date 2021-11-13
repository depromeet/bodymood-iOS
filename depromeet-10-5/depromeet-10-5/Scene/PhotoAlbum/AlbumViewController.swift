import UIKit
import Photos
import Combine

class AlbumViewController: UIViewController {
	typealias DataSource = UICollectionViewDiffableDataSource<Section, PHAsset>
	typealias SnapShot = NSDiffableDataSourceSnapshot<Section, PHAsset>
	typealias CellRegistration = UICollectionView.CellRegistration<PhotoCell, PHAsset>

	enum Section {
		case main
	}

	enum Layout {
		static let itemSpacing: CGFloat = 1

		static let btnHeight: CGFloat = 56
	}

	private lazy var collectionView: UICollectionView = { createCollectionView() }()
	private lazy var dataSource: DataSource = { createDataSource() }()
	private let refreshControl = UIRefreshControl()
	private lazy var selectButton: DefaultBottomButton = { createSelectButton() }()
	private var subscriptions = Set<AnyCancellable>()
	private let viewModel: AlbumViewModelType

	init(viewModel: AlbumViewModelType) {
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

	private func bind() {
		viewModel.photos
			.receive(on: DispatchQueue.main)
			.sink { [weak self] photos in
				self?.collectionView.allowsSelection = false
				self?.collectionView.allowsSelection = true
				self?.updatePhotos(photos)
			}.store(in: &subscriptions)

		viewModel.selectBtnTitle
			.receive(on: DispatchQueue.main)
			.sink { [weak self] title in
                self?.selectButton.label.text = title
			}.store(in: &subscriptions)

		viewModel.title
			.receive(on: DispatchQueue.main)
			.sink { [weak self] title in
				self?.navigationItem.title = title
			}.store(in: &subscriptions)

		navigationItem.leftBarButtonItem?.tap
			.sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
			}.store(in: &subscriptions)

		selectButton.publisher(for: .touchUpInside)
			.sink { [weak self] _ in
				guard
					let self = self,
					let indexPath = self.collectionView.indexPathsForSelectedItems?.first
				else { return }
				self.viewModel.nextBtnTapped.send(indexPath)
                self.navigationController?.popViewController(animated: true)
			}.store(in: &subscriptions)

		refreshControl.publisher(for: .valueChanged)
			.compactMap { [weak self] _ in
				return self?.viewModel.loadImage()
			}.flatMap { $0 }
			.filter { $0 }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.refreshControl.endRefreshing()
                self?.selectButton.isEnabled = false
			}.store(in: &subscriptions)
	}

	func updatePhotos(_ photos: [PHAsset], animatingDifferences: Bool = true) {
		var snapshot = SnapShot()
		snapshot.appendSections([.main])
		snapshot.appendItems(photos, toSection: .main)
		dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
	}
}

// MARK: - Configure UI
extension AlbumViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

	private func createSelectButton() -> DefaultBottomButton {
        let view = DefaultBottomButton()
        view.isEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
		return view
	}

	private func createCollectionView() -> UICollectionView {
		let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
		view.backgroundColor = .clear
		view.refreshControl = refreshControl
		view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
		return view
	}

	private func createDataSource() -> DataSource {
		let registration = CellRegistration { cell, _, item in
			cell.update(with: item)
		}

		return DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
			collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
		}
	}

	private var collectionViewLayout: UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] _, env in
			let width = env.container.contentSize.width
			let numOfItemsPerRow = CGFloat(self?.viewModel.numOfItemsPerRow ?? 1)

			let itemWidth = (width - Layout.itemSpacing * (numOfItemsPerRow - 1)) / numOfItemsPerRow

			let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth),
												  heightDimension: .absolute(itemWidth))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												   heightDimension: .absolute(itemWidth))
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
														   subitems: [item])
			group.interItemSpacing = .fixed(Layout.itemSpacing)

			let section = NSCollectionLayoutSection(group: group)
			section.interGroupSpacing = Layout.itemSpacing
			return section
		}
		return layout
	}

	private func style() {
        view.backgroundColor = .white

        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()

		navigationController?.navigationBar.titleTextAttributes = [
			.font: UIFont.systemFont(ofSize: 16),
			.foregroundColor: UIColor.black
		]
		let backIcon = ImageResource.leftArrow?.withTintColor(#colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1), renderingMode: .alwaysOriginal)
		navigationItem.leftBarButtonItem = .init(image: backIcon, style: .plain, target: nil, action: nil)
	}

	private func layout() {
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: selectButton.topAnchor)
		])

		NSLayoutConstraint.activate([
			selectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			selectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			selectButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
}

extension AlbumViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let shouldSelect: Bool
		if collectionView.cellForItem(at: indexPath)?.isSelected ?? false {
			collectionView.deselectItem(at: indexPath, animated: false)
			shouldSelect = false
		} else {
            shouldSelect = true
		}
        selectButton.isEnabled = shouldSelect
        return shouldSelect
	}
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.panGestureRecognizer.translation(in: scrollView).y
        navigationController?.setNavigationBarHidden(value < 0, animated: true)
    }
}
