import UIKit
import Combine

class ExerciseCategoryPageViewController: UIPageViewController {
    private var vcList: [UIViewController] = []
    private let viewModel: ExerciseRecordViewModelType
    private var bag = Set<AnyCancellable>()
    
    private var previousPage = 0

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

        viewModel.currentIdxOfFirstDepth
            .receive(on: DispatchQueue.main)
            .sink { [weak self] idx in
                guard let self = self,
                      let nextVC = self.vcList[safe: idx]
                else { return }
                let direction: UIPageViewController.NavigationDirection = self.previousPage < idx ? .forward : .reverse
                self.setViewControllers([nextVC], direction: direction, animated: true, completion: nil)
                self.previousPage = idx
            }.store(in: &bag)
    }

    private func update(with list: [ExerciseCategoryModel]) {
        vcList = list.compactMap { model in
            let list = model.children?.compactMap { $0 }
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
