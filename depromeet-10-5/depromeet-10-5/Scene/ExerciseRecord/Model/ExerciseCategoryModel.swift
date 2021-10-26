import Foundation

struct ExerciseCategoryModel: Codable {
    let name: String
    let description: String
    let depth: Int
    let children: [ExerciseCategoryModel]?
}

struct ExerciseItemModel: Hashable {
    private let identifier = UUID()
    let english: String
    let korean: String
}
