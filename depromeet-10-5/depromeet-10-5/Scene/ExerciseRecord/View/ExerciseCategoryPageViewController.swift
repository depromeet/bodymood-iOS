import UIKit
import Combine

class ExerciseCategoryPageViewController: UIPageViewController {
    private var vcList: [UIViewController] = []
    private let viewModel: ExerciseRecordViewModelType
    private var bag = Set<AnyCancellable>()

    init(with viewModel: ExerciseRecordViewModelType) {
        self.viewModel = viewModel
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        delegate = self
        dataSource = self
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    
    private func bind() {
        viewModel.categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] list in
                self?.update(with: list)
            }.store(in: &bag)
    }

    private func update(with list: [ExerciseCategoryModel]) {
        vcList = list.compactMap { model in
            let list = model.children?.compactMap { ExerciseItemModel(english: $0.name, korean: $0.description) }
            return ExerciseListViewController(with: list ?? [], viewModel: viewModel)
        }
        if let firstVC = vcList.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
}

extension ExerciseCategoryPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = vcList.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        if previousIndex < 0 {
            return nil
        }
        return vcList[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = vcList.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex == vcList.count {
            return nil
        }
        return vcList[nextIndex]
    }
}

extension ExerciseCategoryPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard let currentVC = pageViewController.viewControllers?.first,
              let currentIndex = vcList.firstIndex(of: currentVC) else { return }
        viewModel.currentIdxOfFirstDepth.send(currentIndex)
    }
}

