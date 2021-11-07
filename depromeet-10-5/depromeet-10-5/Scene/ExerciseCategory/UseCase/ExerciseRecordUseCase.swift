import Photos
import Combine
import Foundation

protocol ExerciseRecordUseCaseType {
    func fetch() -> AnyPublisher<[ExerciseCategoryModel], Error>
}

class ExerciseRecordUseCase: ExerciseRecordUseCaseType {
    static let cache = NSCache<NSString, CachedExerciseCategoryModel>()
    static let cacheKey: NSString = "CachedExerciseCategoryModel"

    func fetch() -> AnyPublisher<[ExerciseCategoryModel], Error> {
        if let object = Self.cache.object(forKey: Self.cacheKey) {
            return Just(object.list).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return BodyMoodAPIService.shared.fetchExerciseCategory().map { list in
                let object = CachedExerciseCategoryModel(list)
                Self.cache.setObject(object, forKey: Self.cacheKey)
                return list
            }.eraseToAnyPublisher()
        }
    }
}

class CachedExerciseCategoryModel {
    let list: [ExerciseCategoryModel]
    init(_ list: [ExerciseCategoryModel]) {
        self.list = list
    }
}
