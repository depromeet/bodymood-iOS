import Combine
import UIKit

class MyPageViewController: UIViewController {
    private lazy var titleLabel: UILabel = {
        createTitleLabel()
    }()

    private lazy var userInfoButton: UIButton = { createUserInfoButton() }()
    private lazy var agreementButton: UIButton = { createAgreementButton() }()
    private lazy var removeAccountButton: UIButton = { createRemoveAccountButton() }()
    private lazy var logoutButton: UIButton = { createLogoutButton() }()
    private lazy var stackView: UIStackView = { createStackView() }()

    private var viewModel: MypageViewModelType
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
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

        userInfoButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.moveToUserInfo.send()
        }.store(in: &subscriptions)

        agreementButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.moveToAgreement.send()
        }.store(in: &subscriptions)

        removeAccountButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.moveToRemoveAccount.send()
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

    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = label
        return label
    }

    private func createUserInfoButton() -> UIButton {
        let button = UIButton()
        button.setTitle("계정 정보", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        button.contentHorizontalAlignment = .leading
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func createAgreementButton() -> UIButton {
        let button = UIButton()
        button.setTitle("개인정보 약관 동의", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        button.contentHorizontalAlignment = .leading
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func createRemoveAccountButton() -> UIButton {
        let button = UIButton()
        button.setTitle("계정 삭제", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        button.contentHorizontalAlignment = .leading
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func createStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [userInfoButton, agreementButton, removeAccountButton])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        return stackView
    }

    private func createLogoutButton() -> UIButton {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        return button
    }

    private func style() {
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = .init(
            image: UIImage(named: "back_black"),
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
    }

    private func layout() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28)
        ])

        NSLayoutConstraint.activate([
            userInfoButton.heightAnchor.constraint(equalToConstant: 54)
        ])

        NSLayoutConstraint.activate([
            agreementButton.heightAnchor.constraint(equalToConstant: 54)
        ])

        NSLayoutConstraint.activate([
            removeAccountButton.heightAnchor.constraint(equalToConstant: 54)
        ])

        NSLayoutConstraint.activate([
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            logoutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
}
