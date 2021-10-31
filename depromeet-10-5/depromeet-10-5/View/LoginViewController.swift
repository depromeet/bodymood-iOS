import Combine
import UIKit

import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

class LoginViewController: UIViewController, Coordinating {
    var coordinator: Coordinator?

    private lazy var kakaoLoginButton: UIButton = { createKakaoButton() }()
    private lazy var appleLoginButton: UIButton = { createAppleButton() }()
    private lazy var stackView: UIStackView = { createStackView() }()
    private var authViewModel: AuthViewModelType

    private var subscriptions: Set<AnyCancellable> = []
    private var kakaoAccessToken: String?
    private var appleAccessToken: String?

    init(viewModel: AuthViewModelType) {
        self.authViewModel = viewModel
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
        bind()

//        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
//            let viewController = EmotionViewController(viewModel: EmotionViewModel(service: EmotionService()))
//            self.navigationController?.pushViewController(viewController, animated: true)
//        }
    }

    private func bind() {
        authViewModel.kakaoBtnTapped.receive(on: DispatchQueue.main).sink { _ in
            Log.debug("kakaoLogin Button Tapped")

        }.store(in: &subscriptions)
    }
}

extension LoginViewController {
    private func createKakaoButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "kakao_login"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(kakaoLoginButtonDidTap), for: .touchUpInside)
        return button
    }

    private func createAppleButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "apple_login"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(appleLoginDidTap), for: .touchUpInside)
        return button
    }

    private func createStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [kakaoLoginButton, appleLoginButton])

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 18.0
        return stackView
    }

    func style() {
        view.backgroundColor = .white
    }

    func layout() {
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        kakaoLoginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            kakaoLoginButton.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            kakaoLoginButton.widthAnchor.constraint(equalToConstant: 300),
            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 45)
        ])

        appleLoginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appleLoginButton.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            appleLoginButton.widthAnchor.constraint(equalToConstant: 300),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
}

extension LoginViewController {
    @objc func kakaoLoginButtonDidTap() {
    
        let kakaoLogin = authViewModel.kakaoLoginAvailable()

        kakaoLogin.sink( receiveCompletion: { [weak self] completion in
            guard let self = self else { return }
            switch completion {
            case .finished:
                self.authViewModel.kakaoLogin(accessToken: self.kakaoAccessToken ?? "")

                if UserDefaults.standard.string(forKey: UserDefaultKey.accessToken) != "" {
                    self.moveToPosterList()
                }

            case .failure(let error):
                Log.debug(error)
            }
        }, receiveValue: { [weak self] result in
            Log.debug("====\(result.accessToken)====")
            self?.kakaoAccessToken = result.accessToken
        }).store(in: &subscriptions)
    }

    func moveToPosterList() {
        let mainVM = PosterListViewModel(useCase: AlbumUseCase())
        let mainVC = PosterListViewController(viewModel: mainVM)
        let nav = MainNavigationController(rootViewController: mainVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
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
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            let token = appleIDCredential.identityToken
            let tokenToUTF8 = String(data: token!, encoding: .utf8)!
            appleAccessToken = tokenToUTF8

            Log.debug("user token: \(String(describing: tokenToUTF8))")
            Log.debug("User ID: \(userIdentifier)")
            Log.debug("User full name: \(String(describing: fullName))")
            Log.debug("User email: \(String(describing: email))")

            self.authViewModel.appleLogin(accessToken: self.appleAccessToken ?? "")

            if UserDefaults.standard.string(forKey: UserDefaultKey.accessToken) != "" {
                let cameraViewController = CameraViewController()
                self.navigationController?.pushViewController(cameraViewController, animated: true)
            }

        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Log.debug("login error")
    }
}
