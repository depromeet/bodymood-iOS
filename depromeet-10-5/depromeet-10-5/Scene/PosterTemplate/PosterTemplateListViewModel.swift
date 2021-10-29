import Photos
import Combine
import UIKit

protocol PosterTemplateListViewModelType {
    // Inputs
    var selectBtnTapped: PassthroughSubject<Void, Never> { get }
    var templateSelected: PassthroughSubject<Int, Never> { get }

    // Outputs
    var templates: CurrentValueSubject<[PosterTemplate], Never> { get }
    var title: CurrentValueSubject<String, Never> { get }
    var selectBtnTitle: CurrentValueSubject<String, Never> { get }
    var moveToPosterEdit: PassthroughSubject<PosterTemplate.TemplateType, Never> { get }
}

class PosterTemplateListViewModel: PosterTemplateListViewModelType {
    let selectBtnTapped = PassthroughSubject<Void, Never>()
    let templateSelected = PassthroughSubject<Int, Never>()

    let templates: CurrentValueSubject<[PosterTemplate], Never>
    let title: CurrentValueSubject<String, Never>
    let selectBtnTitle: CurrentValueSubject<String, Never>
    let moveToPosterEdit = PassthroughSubject<PosterTemplate.TemplateType, Never>()

    private var bag = Set<AnyCancellable>()

    init() {
        let list: [PosterTemplate] = [
            .init(identifier: 0, imageName: "poster_template1", type: .normal),
            .init(identifier: 1, imageName: "poster_tbd", type: nil),
            .init(identifier: 2, imageName: "poster_tbd", type: nil)
        ]
        templates = .init(list)
        selectBtnTitle = .init(CommonText.selectTemplateBtnText)
        title = .init(CommonText.templateListViewTitle)

        bind()
    }
    deinit {
        Log.debug(Self.self, #function)
    }

    private func bind() {
        selectBtnTapped.combineLatest(templateSelected)
            .map { $0.1 }
            .sink { [weak self] index in
                guard
                    let self = self,
                    let type = self.templates.value[safe: index]?.type
                else { return }
                self.moveToPosterEdit.send(type)
            }.store(in: &bag)
    }
}
