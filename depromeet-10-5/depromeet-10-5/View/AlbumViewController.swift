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
		static let listViewHorizontalInset: CGFloat = 16
		static let listViewTopInset: CGFloat = 10
		static let listViewBottomInset: CGFloat = 56
		static let itemSpacing: CGFloat = 10

		static let btnHorizontalInset: CGFloat = 20
		static let btnBottomInset: CGFloat = 30
		static let btnHeight: CGFloat = 56
	}

	private lazy var collectionView: UICollectionView = { createCollectionView() }()
	private lazy var dataSource: DataSource = { createDataSource() }()
	private let refreshControl = UIRefreshControl()
	private lazy var nextButton: UIButton = { createNextButton() }()
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

		viewModel.nextBtnTitle
			.receive(on: DispatchQueue.main)
			.sink { [weak self] title in
				self?.nextButton.setTitle(title, for: .normal)
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

		nextButton.publisher(for: .touchUpInside)
			.sink { [weak self] _ in
				guard
					let self = self,
					let indexPath = self.collectionView.indexPathsForSelectedItems?.first
				else { return }
				self.viewModel.nextBtnTapped.send(indexPath)
			}.store(in: &subscriptions)

		refreshControl.publisher(for: .valueChanged)
			.compactMap { [weak self] _ in
				return self?.viewModel.loadImage()
			}.flatMap { $0 }
			.filter { $0 }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.refreshControl.endRefreshing()
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
	private func createNextButton() -> UIButton {
		let view = UIButton()
		view.backgroundColor = #colorLiteral(red: 0.2196078431, green: 0.7215686275, blue: 1, alpha: 1)
		view.setTitleColor(.white, for: .normal)
		view.titleLabel?.font = .boldSystemFont(ofSize: 18)
		view.layer.cornerRadius = 12
		view.layer.masksToBounds = true
		return view
	}

	private func createCollectionView() -> UICollectionView {
		let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
		view.backgroundColor = .clear
		view.refreshControl = refreshControl
		view.delegate = self
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
			section.contentInsets = .init(top: Layout.listViewTopInset,
										  leading: 0,
										  bottom: Layout.listViewBottomInset,
										  trailing: 0)
			return section
		}
		return layout
	}

	private func style() {
		view.backgroundColor = .white

		navigationController?.navigationBar.titleTextAttributes = [
			.font: UIFont.systemFont(ofSize: 16),
			.foregroundColor: UIColor.black
		]
		let backIcon = ImageResource.leftArrow?.withTintColor(#colorLiteral(red: 0.6509803922, green: 0.6549019608, blue: 0.6509803922, alpha: 1), renderingMode: .alwaysOriginal)
		navigationItem.leftBarButtonItem = .init(image: backIcon, style: .plain, target: nil, action: nil)
	}

	private func layout() {
		view.addSubview(collectionView)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
													constant: Layout.listViewHorizontalInset),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
													 constant: -Layout.listViewHorizontalInset),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])

		view.addSubview(nextButton)
		nextButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
												constant: Layout.btnHorizontalInset),
			nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
												 constant: -Layout.btnHorizontalInset),
			nextButton.heightAnchor.constraint(equalToConstant: Layout.btnHeight),
			nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
											   constant: -Layout.btnBottomInset)
		])
	}
}

extension AlbumViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		if collectionView.cellForItem(at: indexPath)?.isSelected ?? false {
			collectionView.deselectItem(at: indexPath, animated: false)
			return false
		} else {
			return true
		}
	}
}

// TODO: 테스트 용 코드, 추후 제거할 것
func presentAlbumVC(on viewController: UIViewController) {
	let vc = AlbumViewController(viewModel: AlbumViewModel(useCase: AlbumUseCase()))
	let nav = UINavigationController(rootViewController: vc)
	nav.overrideUserInterfaceStyle = .light
	nav.modalPresentationStyle = .fullScreen
	viewController.present(nav, animated: true, completion: nil)
}
