struct ExerciseCategoryAPIResponseModel: Codable {
    let code: String
    let message: String
    let data: [ExerciseCategoryModel]
}
