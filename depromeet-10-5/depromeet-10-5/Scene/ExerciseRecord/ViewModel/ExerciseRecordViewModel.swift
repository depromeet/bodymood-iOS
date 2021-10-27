import Photos
import Combine
import UIKit

protocol ExerciseRecordViewModelType: ExerciseListViewModelType {
    // Outputs
    var categories: CurrentValueSubject<[ExerciseCategoryModel], Never> { get }
    var firstDepthCategories: CurrentValueSubject<[ExerciseItemModel], Never> { get }
    var buttonTitle: CurrentValueSubject<String, Never> { get }
    var canEnableButton: CurrentValueSubject<Bool, Never> { get }
    var canShowButton: CurrentValueSubject<Bool, Never> { get }
    var currentIdxOfFirstDepth: CurrentValueSubject<Int, Never> { get }
    
    // Inputs
    var selectBtnTapped: PassthroughSubject<Void, Never> { get }
}

protocol ExerciseListViewModelType {
    var itemTapped: PassthroughSubject<Int, Never> { get }
    var shouldSelectItem: PassthroughSubject<Int, Never> { get }
    var shouldDeselectItem: PassthroughSubject<Int, Never> { get }
    var bgColorHexPair: CurrentValueSubject<(Int, Int), Never> { get }
}

class ExerciseRecordViewModel: ExerciseRecordViewModelType {

    private let maxNumOfExercise = 3
    private let useCase: ExerciseRecordUseCaseType
    private var fetchSubscription: AnyCancellable?
    private var bag = Set<AnyCancellable>()
    private let selectedExerciseList = CurrentValueSubject<[IndexPath], Never>([])
    private let resultReciever: CurrentValueSubject<[ExerciseItemModel], Never>

    let categories = CurrentValueSubject<[ExerciseCategoryModel], Never>([])
    let buttonTitle = CurrentValueSubject<String, Never>("")
    let shouldSelectItem = PassthroughSubject<Int, Never>()
    let shouldDeselectItem = PassthroughSubject<Int, Never>()
    let canEnableButton = CurrentValueSubject<Bool, Never>(false)
    let canShowButton = CurrentValueSubject<Bool, Never>(true)
    let bgColorHexPair: CurrentValueSubject<(Int, Int), Never>
    let firstDepthCategories = CurrentValueSubject<[ExerciseItemModel], Never>([])

    let selectBtnTapped = PassthroughSubject<Void, Never>()
    let currentIdxOfFirstDepth = CurrentValueSubject<Int, Never>(0)
    let itemTapped = PassthroughSubject<Int, Never>()

    init(useCase: ExerciseRecordUseCaseType,
         bgColorHexPair: (Int, Int) = (0xffffff, 0xffffff),
         resultReciever: CurrentValueSubject<[ExerciseItemModel], Never>) {
        self.useCase = useCase
        self.resultReciever = resultReciever

        self.bgColorHexPair = .init(bgColorHexPair)
        fetchCategories()
        bind()
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    private func bind() {
        itemTapped
            .sink { [weak self] tappedIndex in
                guard let self = self else { return }
                let value: IndexPath = [self.currentIdxOfFirstDepth.value, tappedIndex]
                var list = self.selectedExerciseList.value
                if let idx = list.firstIndex(of: value) {
                    list.remove(at: idx)
                    self.shouldDeselectItem.send(tappedIndex)
                } else if self.maxNumOfExercise > self.selectedExerciseList.value.count {
                    list.append(value)
                    self.shouldSelectItem.send(tappedIndex)
                }
                self.selectedExerciseList.send(list)
            }.store(in: &bag)

        selectedExerciseList
            .map { $0.count }
            .sink { [weak self] cnt in
                guard let self = self else { return }
                self.buttonTitle.send("운동 선택 (\(cnt)/\(self.maxNumOfExercise))")
                self.canEnableButton.send(self.maxNumOfExercise == cnt)
                self.canShowButton.send(cnt > 0)
            }.store(in: &bag)

        selectBtnTapped
            .sink { [weak self] _ in
                guard let self = self else { return }
                let list = self.selectedExerciseList.value.compactMap {
                    self.categories.value[safe: $0.section]?.children?[safe: $0.item]
                }.map { ExerciseItemModel(english: $0.name, korean: $0.description) }
                self.resultReciever.send(list)
            }.store(in: &bag)
    }

    private func fetchCategories() {
        fetchSubscription = useCase.fetch().sink { [weak self] list in
            self?.categories.send(list)
            self?.firstDepthCategories.send(list.map { .init(english: $0.name, korean: $0.description) })
        }
    }
}
