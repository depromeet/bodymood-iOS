import Combine
import UIKit

import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

class LoginViewController: UIViewController, Coordinating {
    enum Layout {
        static let buttonWidth: CGFloat = 300
        static let buttonHeight: CGFloat = 45
        static let stackViewSpacing: CGFloat = 18
    }
    var coordinator: Coordinator?

    private lazy var kakaoLoginButton: UIButton = { createKakaoButton() }()
    private lazy var appleLoginButton: UIButton = { createAppleButton() }()
    private lazy var stackView: UIStackView = { createStackView() }()
    private var loginViewModel: LoginViewModelType

    private var subscriptions: Set<AnyCancellable> = []
    private var kakaoAccessToken: String?
    private var appleAccessToken: String?

    init(viewModel: LoginViewModelType) {
        self.loginViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        style()
        layout()
    }
}

extension LoginViewController {
    private func createKakaoButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "kakao_login"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(kakaoLoginButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func createAppleButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "apple_login"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(appleLoginDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func createStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [kakaoLoginButton, appleLoginButton])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = Layout.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        return stackView
    }

    func style() {
        view.backgroundColor = .white
    }

    func layout() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            kakaoLoginButton.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            kakaoLoginButton.widthAnchor.constraint(equalToConstant: Layout.buttonWidth),
            kakaoLoginButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ])

        NSLayoutConstraint.activate([
            appleLoginButton.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            appleLoginButton.widthAnchor.constraint(equalToConstant: Layout.buttonWidth),
            appleLoginButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ])
    }
}

// MARK: - Configure Actions
extension LoginViewController {
    @objc func kakaoLoginButtonDidTap() {
        let kakaoLogin = loginViewModel.kakaoLoginAvailable()

        kakaoLogin.sink( receiveCompletion: { [weak self] completion in
            guard let self = self else { return }
            switch completion {
            case .finished:
                self.loginViewModel.kakaoLogin(accessToken: self.kakaoAccessToken ?? "")

                if UserDefaults.standard.string(forKey: UserDefaultKey.accessToken) != "" {
                    self.moveToPosterList()
                }

            case .failure(let error):
                Log.debug(error)
            }
        }, receiveValue: { [weak self] result in
            self?.kakaoAccessToken = result.accessToken
        }).store(in: &subscriptions)
    }

    @objc func appleLoginDidTap() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func moveToPosterList() {
        let mainVM = PosterListViewModel(useCase: AlbumUseCase())
        let mainVC = PosterListViewController(viewModel: mainVM)
        let nav = MainNavigationController(rootViewController: mainVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let token = appleIDCredential.identityToken
            let tokenToUTF8 = String(data: token!, encoding: .utf8)!
            Log.debug(tokenToUTF8)
            appleAccessToken = tokenToUTF8

            self.loginViewModel.appleLogin(accessToken: self.appleAccessToken ?? "")

            if UserDefaults.standard.string(forKey: UserDefaultKey.accessToken) != "" {
//                let name = appleIDCredential.fullName
//                Log.debug(name)
//                UserDefaults.standard.set(name, forKey: UserDefaultKey.userName)
                moveToPosterList()
            }

        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Log.error("login error")
    }
}
