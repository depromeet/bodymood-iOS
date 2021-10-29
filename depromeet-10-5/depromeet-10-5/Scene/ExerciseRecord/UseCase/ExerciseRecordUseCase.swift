import Photos
import Combine

protocol ExerciseRecordUseCaseType {
    func fetch() -> AnyPublisher<[ExerciseCategoryModel], Never>
}

class ExerciseRecordUseCase: ExerciseRecordUseCaseType {

    func fetch() -> AnyPublisher<[ExerciseCategoryModel], Never> {
        return Just(getDummy()).eraseToAnyPublisher()
    }
    
    private func getDummy() -> [ExerciseCategoryModel] {
        guard
            let url = Bundle.main.url(forResource: "ExerciseCategory", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let model = try? JSONDecoder().decode(ExerciseCategoryAPIResponseModel.self, from: data)
        else { return [] }
        
        return model.data
    }
}
