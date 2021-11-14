struct PosterTemplate: Hashable {
    enum TemplateType {
        case normal
    }

    let identifier: Int
    let imageName: String
    let type: TemplateType?
}
