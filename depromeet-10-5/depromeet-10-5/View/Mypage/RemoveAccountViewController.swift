import Combine
import UIKit

class RemoveAccountViewController: UIViewController {
    private let viewModel: RemoveAccountViewModelType
    private var subscriptions = Set<AnyCancellable>()

    private lazy var titleLabel: UILabel = { createTitleLabel() }()
    private lazy var contentLabel: UILabel = { createContentLabel() }()
    private lazy var removeView: UIView = { createRemoveView() }()
    private lazy var removeButton: UIButton = { createRemoveButton() }()

    init(viewModel: RemoveAccountViewModelType) {
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

// MARK: - Configure bind
extension RemoveAccountViewController {
    private func bind() {
        viewModel.title.sink { [weak self] title in
            self?.titleLabel.text = title
        }.store(in: &subscriptions)
        
        viewModel.content.sink { [weak self] content in
            self?.contentLabel.text = content
        }.store(in: &subscriptions)
        
        viewModel.removeButton.sink { [weak self] title in
            self?.removeButton.setTitle(title, for: .normal)
        }.store(in: &subscriptions)
        
        viewModel.removeAccountIsSuccess.receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                if success {
                    self?.clearDefaultKeys()
                    self?.moveToLogin()
                } else {
                    self?.removeAccountFailureAlert()
                }
            }.store(in: &subscriptions)
        
        navigationItem.leftBarButtonItem?.tap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
        }.store(in: &subscriptions)
        
        removeButton.publisher(for: .touchUpInside).sink { [weak self] _ in
            self?.removeButton.isEnabled = false
            self?.removeCheckAlert()
        }.store(in: &subscriptions)
    }
}

// MARK: - Configure UI
extension RemoveAccountViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
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

    private func createContentLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        return label
    }

    private func createRemoveView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    private func createRemoveButton() -> UIButton {
        let button = UIButton()
        button.isEnabled = true
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        removeView.addSubview(button)
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
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 17),
            contentLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            contentLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 28),
            contentLabel.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            removeView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            removeView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -20),
            removeView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
            removeView.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        NSLayoutConstraint.activate([
            removeButton.topAnchor.constraint(equalTo: removeView.topAnchor),
            removeButton.leadingAnchor.constraint(equalTo: removeView.leadingAnchor),
            removeButton.bottomAnchor.constraint(equalTo: removeView.bottomAnchor),
            removeButton.trailingAnchor.constraint(equalTo: removeView.trailingAnchor)
        ])
    }
}

// MARK: - Configure Actions
extension RemoveAccountViewController {
    private func removeCheckAlert() {
        let alert = UIAlertController(title: "계정 삭제", message: "계정을 삭제하시겠습니까?", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.removeAccount()
        }
        
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func removeAccount() {
        let remove = viewModel.removeAccount()
        remove.sink(receiveCompletion: { [weak self] completion in
            
            self?.removeButton.isEnabled = true
            
            switch completion {
            case .finished:
                Log.debug("삭제 완료")
                
            case .failure(let error):
                Log.error(error)
            }
        }, receiveValue: { response in
            Log.debug(response)
        }).store(in: &subscriptions)
    }
    
    private func clearDefaultKeys() {
        UserDefaultKey.keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }

    private func moveToLogin() {
        // TODO: 뷰전환 로직 수정 필요
        dismiss(animated: false) { [weak self] in
            let loginVC = LoginViewController(viewModel: LoginViewModel(service: AuthService()))
            loginVC.modalPresentationStyle = .fullScreen
            self?.navigationController?.present(loginVC, animated: false) {
                self?.navigationController?.popToRootViewController(animated: false)
            }
        }
    }
    
    private func removeAccountFailureAlert() {
        let alert = UIAlertController(title: "계정 삭제 실패", message: "계정 삭제를 다시 시도해주세요", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
