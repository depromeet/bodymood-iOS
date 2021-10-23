import Combine
import UIKit

import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

class LoginViewController: UIViewController, Coordinating {
    
    var coordinator: Coordinator?
    
    lazy var authViewModel: AuthViewModel = {
        let viewModel = AuthViewModel()
        return viewModel
    }()

    var subscription: Set<AnyCancellable> = []

    private var kakaoLoginSubscriber: AnyCancellable?
    private var accessToken: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundView: UIView = {
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            view.addSubview(backgroundView)
            backgroundView.backgroundColor = .blue
            return backgroundView
        }()
        
        let buttonContainerView: UIView = {
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 128))
            backgroundView.addSubview(containerView)
            containerView.backgroundColor = .green

            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = .green
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
            containerView.widthAnchor.constraint(equalToConstant: 327).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: 500).isActive = true
            return containerView
        }()
        
        let kakaoLoginButton: UIButton = {
            let button = UIButton()
            buttonContainerView.addSubview(button)
            button.setTitleColor(.white, for: .normal)
            button.setImage(UIImage(named: "kakao_login_large_wide"), for: .normal)
            button.imageView?.contentMode = .scaleAspectFill
            button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: 327).isActive = true
            button.heightAnchor.constraint(equalToConstant: 56).isActive = true

            return button
        }()
        
        let appleLoginButton: UIButton = {
            let button = UIButton()
            buttonContainerView.addSubview(button)

            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(.white, for: .normal)
            button.setImage(UIImage(named: "apple_login"), for: .normal)
            button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)

            button.topAnchor.constraint(equalTo: kakaoLoginButton.bottomAnchor, constant: 16).isActive = true
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: 327).isActive = true
            button.heightAnchor.constraint(equalToConstant: 56).isActive = true
            return button
        }()
    }

    @objc func buttonDidTap() {
        let kakaoLoginFuture = authViewModel.loginAvailable()

        _ = kakaoLoginFuture.sink( receiveCompletion: { completion in
            switch completion {
                case .finished:
                self.authViewModel.kakaoAuth(accessToken: self.accessToken ?? "")
                
                if(UserDefaults.standard.string(forKey: UserDefaultKey.accessToken) != "") {
                    self.coordinator?.eventOccured(with: .buttonDidTap)
                }
                
                case .failure(let error):
                    Log.debug(error)
                }
            }, receiveValue: {
                Log.debug("====\($0.accessToken)====")
                self.accessToken = $0.accessToken
            }).store(in: &subscription)

    }
}
