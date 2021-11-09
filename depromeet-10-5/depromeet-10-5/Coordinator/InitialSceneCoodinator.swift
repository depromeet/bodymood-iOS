import UIKit
import Combine

class InitialSceneCoodinator {
    weak var window: UIWindow?
    var bag = Set<AnyCancellable>()
    
    let tokenErrorOccured = CurrentValueSubject<Bool, Never>(false)
    let splashVC = SplashViewController()
    var mainNav: UINavigationController = {
        let mainVM = PosterListViewModel(useCase: PosterUseCase())
        let mainVC = PosterListViewController(viewModel: mainVM)
        return MainNavigationController(rootViewController: mainVC)
    }()
    
    var loginVC: UIViewController = {
        let loginVM = LoginViewModel(service: AuthService())
        return LoginViewController(viewModel: loginVM)
    }()
    
    init() {
        BodyMoodAPIService.shared.fetchUserInfo()
            .sink { [weak self] completion in
                print(completion)
                if case let .failure(error) = completion,
                   (error as? NetworkError) == .tokenError {
                    UserDefaultKey.keys.forEach {
                        UserDefaults.standard.removeObject(forKey: $0)
                    }
                    self?.tokenErrorOccured.send(true)
                }
            } receiveValue: { _ in
            }.store(in: &bag)
        
        splashVC.animationFinished.combineLatest(tokenErrorOccured)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, tokenError in
                guard let self = self else { return }
                if tokenError {
                    self.loginVC.modalPresentationStyle = .fullScreen
                    self.mainNav.present(self.loginVC, animated: false) {
                        self.removeSplashView()
                    }
                } else {
                    self.removeSplashView()
                }
            }.store(in: &bag)
    }

    func removeSplashView() {
        mainNav.isNavigationBarHidden = false
        splashVC.remove()
    }

    func start() {
        guard let window = window else { return }
        mainNav.viewControllers.first?.add(splashVC)
        window.rootViewController = mainNav
        window.makeKeyAndVisible()
    }
}
