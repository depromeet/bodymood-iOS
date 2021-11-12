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
    private lazy var developerLoginButton: UIButton = { createDeveloperLoginButton() }()
    private lazy var stackView: UIStackView = { createStackView() }()
    private var loginViewModel: LoginViewModelType

    private var subscriptions: Set<AnyCancellable> = []
    private var kakaoAccessToken: String?
    private var appleAccessToken: String?
    private var userInfo: UserDataResponse?

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
        bind()
        #if DEBUG
        addDeveloperAccountLoginButton()
        #endif
        
    }
}

extension LoginViewController {
    private func bind() {
        loginViewModel.moveToPoster
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.moveToPosterList()
            }.store(in: &subscriptions)
        
        kakaoLoginButton.publisher(for: .touchUpInside).sink { [weak self] _ in
            self?.kakaoLoginButtonDidTap()
        }.store(in: &subscriptions)
        
        appleLoginButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.appleLoginDidTap()
            }.store(in: &subscriptions)
    }
}
extension LoginViewController {
    private func createKakaoButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "kakao_login"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func createAppleButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "apple_login"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func createDeveloperLoginButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        button.setTitle("🥱", for: .normal)
        button.addTarget(self, action: #selector(developerLoginBtnDidTap), for: .touchUpInside)
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
    
    func addDeveloperAccountLoginButton() {
        stackView.addArrangedSubview(developerLoginButton)
        NSLayoutConstraint.activate([
            developerLoginButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ])
    }
}

// MARK: - Configure Actions
extension LoginViewController {
    private func kakaoLoginButtonDidTap() {
        let alert = UIAlertController(title: "카카오 로그인", message: "카카오 로그인 방식을 선택해주세요.", preferredStyle: .actionSheet)
        let talkButton = UIAlertAction(title: "카카오톡으로 로그인", style: .default) { [weak self] _ in
            self?.kakaoTalkLogin()
        }
        
        let accountButton = UIAlertAction(title: "카카오 계정으로 로그인", style: .default) { [weak self] _ in
            self?.kakaoAccountLogin()
        }
        
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(talkButton)
        alert.addAction(accountButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
    private func kakaoTalkLogin() {
        let kakaoLogin = loginViewModel.kakaoLoginAvailable(isTalk: true)
        
        kakaoLogin.sink( receiveCompletion: { [weak self] completion in
            guard let self = self else { return }
            
            switch completion {
            case .finished:
                self.loginViewModel.kakaoLogin(accessToken: self.kakaoAccessToken ?? "")
        
            case .failure(let error):
                        Log.debug(error)
            }
        }, receiveValue: { [weak self] result in
                self?.kakaoAccessToken = result.accessToken
        }).store(in: &subscriptions)
    }
    
    private func kakaoAccountLogin() {
        let kakaoLogin = loginViewModel.kakaoLoginAvailable(isTalk: false)
        
        kakaoLogin.sink( receiveCompletion: { [weak self] completion in
            guard let self = self else { return }
            
            switch completion {
            case .finished:
                self.loginViewModel.kakaoLogin(accessToken: self.kakaoAccessToken ?? "")
        
            case .failure(let error):
                        Log.debug(error)
            }
        }, receiveValue: { [weak self] result in
                self?.kakaoAccessToken = result.accessToken
        }).store(in: &subscriptions)
    }
    
    private func appleLoginDidTap() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    @objc func developerLoginBtnDidTap() {
        loginViewModel.developerLoginButtonDidTap.send()
    }

    private func moveToPosterList() {
        loginViewModel.userInfo()
        receiveUserInfo()
        presentPosterList(in: self)
    }

    private func receiveUserInfo() {
        loginViewModel.userSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                UserDefaults.standard.setValue(response?.name, forKey: UserDefaultKey.userName)
                UserDefaults.standard.setValue(response?.socialProvider, forKey: UserDefaultKey.socialProvider)
                Log.debug("success with login view controller")
        }.store(in: &subscriptions)
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
            
            if UserDefaults.standard.string(forKey: UserDefaultKey.accessToken) != nil {
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
