import Foundation

struct ExerciseCategoryModel: Codable, Hashable {
    let categoryId: Int
    let englishName: String
    let koreanName: String
    let depth: Int
    let children: [ExerciseCategoryModel]?
}
