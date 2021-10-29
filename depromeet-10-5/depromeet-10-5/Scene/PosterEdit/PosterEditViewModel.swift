import Photos
import Combine
import UIKit

protocol PosterEditViewModelType: PosterEditGuideViewModelType {
    // Inputs
    var completeBtnTapped: PassthroughSubject<Void, Never> { get }
    var itemSelected: PassthroughSubject<Int, Never> { get }
    
    // Outputs
    var poster: CurrentValueSubject<PHAsset?, Never> { get }
    var title: CurrentValueSubject<String, Never> { get }
    var moveToCamera: PassthroughSubject<Void, Never> { get }
    var moveToAlbum: PassthroughSubject<Void, Never> { get }
    var moveToExerciseCategory: PassthroughSubject<Void, Never> { get }
    var moveToMoodList: PassthroughSubject<Void, Never> { get }
    var activateCompleteButton: PassthroughSubject<Bool, Never> { get }
    
    // Mediators
    var photoSelectedFromAlbum: PassthroughSubject<PHAsset, Never> { get }
    var exerciseSelected: CurrentValueSubject<[ExerciseItemModel], Never> { get }
}

protocol PosterEditGuideViewModelType {
    var albumBtnTapped: PassthroughSubject<Void, Never> { get }
    var cameraBtnTapped: PassthroughSubject<Void, Never> { get }
    var selectExerciseBtnTapped: PassthroughSubject<Void, Never> { get }
    var selectMoodBtnTapped: PassthroughSubject<Void, Never> { get }
}

class PosterEditViewModel: PosterEditViewModelType {
    

    let completeBtnTapped = PassthroughSubject<Void, Never>()
    let albumBtnTapped = PassthroughSubject<Void, Never>()
    let cameraBtnTapped = PassthroughSubject<Void, Never>()
    let selectExerciseBtnTapped = PassthroughSubject<Void, Never>()
    let selectMoodBtnTapped = PassthroughSubject<Void, Never>()
    let itemSelected = PassthroughSubject<Int, Never>()

    let poster: CurrentValueSubject<PHAsset?, Never>
    let title: CurrentValueSubject<String, Never>
    let moveToCamera = PassthroughSubject<Void, Never>()
    let moveToAlbum = PassthroughSubject<Void, Never>()
    let moveToMoodList = PassthroughSubject<Void, Never>()
    let moveToExerciseCategory = PassthroughSubject<Void, Never>()
    let activateCompleteButton = PassthroughSubject<Bool, Never>()
    
    let photoSelectedFromAlbum = PassthroughSubject<PHAsset, Never>()
    let exerciseSelected = CurrentValueSubject<[ExerciseItemModel], Never>([])

    private var bag = Set<AnyCancellable>()
    private var isSelected = Array(repeating: false, count: 3)

    init(with asset: PHAsset? = nil, templateType: PosterTemplate.TemplateType? = nil) {
        poster = .init(asset)
        title = .init(CommonText.posterEditTitle)
        bind()
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    private func bind() {
        completeBtnTapped
            .sink { [weak self] _ in
                print("completeBtnTapped")
            }.store(in: &bag)

        albumBtnTapped
            .sink { [weak self] _ in
                self?.moveToAlbum.send()
            }.store(in: &bag)

        cameraBtnTapped
            .sink { [weak self] _ in
                self?.moveToCamera.send()
            }.store(in: &bag)

        selectExerciseBtnTapped
            .sink { [weak self] _ in
                self?.moveToExerciseCategory.send()
            }.store(in: &bag)

        selectMoodBtnTapped
            .sink { [weak self] _ in
                self?.moveToMoodList.send()
            }.store(in: &bag)
        
        itemSelected
            .sink { [weak self] idx in
                guard let self = self else { return }
                self.isSelected[safe: idx] = true
                self.activateCompleteButton.send(!self.isSelected.contains(false))
            }.store(in: &bag)
    }
}
