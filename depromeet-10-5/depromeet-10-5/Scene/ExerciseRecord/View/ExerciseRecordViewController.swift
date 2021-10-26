import UIKit
import Combine

class ExerciseRecordViewController: UIViewController {

    private lazy var collectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }()
    
    private lazy var secondDepthCategoryVC: UIPageViewController = {
        let pageVC = ExerciseCategoryPageViewController(with: viewModel)
        addChild(pageVC)
        self.view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        return pageVC
    }()
    
    private lazy var bottomButton: DefaultBottomButton = {
        let view = DefaultBottomButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEnabled = false
        self.view.addSubview(view)
        return view
    }()
    
    private let viewModel: ExerciseRecordViewModelType
    private var bag = Set<AnyCancellable>()

    init(with viewModel: ExerciseRecordViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        bind()
    }

    private func bind() {
        viewModel.bgColorHexPair
            .receive(on: DispatchQueue.main)
            .sink { [weak self] first, second in
                self?.view.addDiagonalGradiant(startColor: UIColor(rgb: first), endColor: UIColor(rgb: second))
            }.store(in: &bag)

        viewModel.canShowButton
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canShow in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.2) {
                    let transform = CGAffineTransform(translationX: 0, y: self.bottomButton.frame.height)
                    self.bottomButton.transform = canShow ? .identity : transform
                }
            }.store(in: &bag)

        viewModel.canEnableButton
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canEnable in
                self?.bottomButton.isEnabled = canEnable
            }.store(in: &bag)

        viewModel.buttonTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.bottomButton.label.text = title
            }.store(in: &bag)

        bottomButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.selectBtnTapped.send(())
            }.store(in: &bag)

        navigationItem.leftBarButtonItem?.tap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }.store(in: &bag)
    }

    private func style() {
        let backIcon = ImageResource.leftArrow?.withTintColor(.black, renderingMode: .alwaysOriginal)
        navigationItem.leftBarButtonItem = .init(image: backIcon, style: .plain, target: nil, action: nil)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ])

        if let subView = secondDepthCategoryVC.view {
            subView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                subView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
                subView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                subView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                subView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }

        NSLayoutConstraint.activate([
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

class ExerciseCategoryCollectionView: UICollectionView {
    
}



// TODO: 테스트 용 코드, 추후 제거할 것
func presentExerciseRecordVC(on viewController: UIViewController) {
    let vc = ExerciseRecordViewController(with: ExerciseRecordViewModel(useCase: ExerciseRecordUseCase(), bgColorHexPair: ((0xAA2900, 0x221E47))))
    let nav = UINavigationController(rootViewController: vc)
    nav.overrideUserInterfaceStyle = .light
    nav.modalPresentationStyle = .fullScreen
    viewController.present(nav, animated: true, completion: nil)
}
