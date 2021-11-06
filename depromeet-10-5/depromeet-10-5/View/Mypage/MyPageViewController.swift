import Combine
import UIKit

class MyPageViewController: UIViewController {
    private let cellIDs = ["UserInfo", "Agreement", "RemoveAccount"]
    private let cellTitle = ["계정정보", "개인정보 약관 동의", "계정 삭제"]

    private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = { createCollectionViewFlowLayout() }()
    private lazy var collectionView: UICollectionView = { createCollectionView() }()
    private lazy var titleLabel: UILabel = {
        createTitleLabel()
    }()

    private var viewModel: MypageViewModelType
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        style()
        bind()
    }

    init(viewModel: MypageViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Log.debug(Self.self, #function)
    }
}

// MARK: - Configure bind
extension MyPageViewController {
    private func bind() {
        viewModel.title.sink { [weak self] title in
            self?.titleLabel.text = title
        }.store(in: &subscriptions)

        viewModel.moveToUserInfo.sink { [weak self] _ in
            let viewController = UserInfoViewController()
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)

        viewModel.moveToAgreement.sink { [weak self] _ in
            let viewController = AgreementViewController()
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)

        viewModel.moveToRemoveAccount.sink { [weak self] _ in
            let viewController = RemoveAccountViewController()
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)

        viewModel.moveToLogout.sink {
            Log.debug("move to user info")
        }.store(in: &subscriptions)

        navigationItem.leftBarButtonItem?.tap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
        }.store(in: &subscriptions)
    }
}

// MARK: - Configure UI
extension MyPageViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    private func createCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        return flowLayout
    }

    private func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        return collectionView
    }

    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = label
        return label
    }

    func style() {
        view.backgroundColor = .white
        let backIcon = ImageResource.leftArrow?.withTintColor(.black, renderingMode: .alwaysOriginal)
        navigationItem.leftBarButtonItem = .init(image: backIcon, style: .plain, target: nil, action: nil)
    }
}

extension MyPageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Log.debug("select \(indexPath.row)")
    }
}

extension MyPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellIDs.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellIDs[indexPath.row],
            for: indexPath) as? MypageCell
        else {
            return UICollectionViewCell()
        }

        cell.update(title: cellTitle[indexPath.row])
        return cell
    }
}

extension MyPageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath)
    -> CGSize {
        return CGSize(width: view.frame.width, height: 54)
    }
}
