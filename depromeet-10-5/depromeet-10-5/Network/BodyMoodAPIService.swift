import Combine
import Foundation
import UIKit

struct BodyMoodAPIService {
    static let shared = BodyMoodAPIService()

    private init() {}

    let baseURL = "https://dev.bodymood.me"
    var token: String {
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo3LCJpc3MiOiJkZ2RnIiwiZXhwIjoxNjM2MzAwNDk1LCJpYXQiOjE2MzYyMTQwOTV9.b4l3ALd5GcBWul1Dwns684ZX9XMLI_GvZuH-HqFMc5w"
    }

    func fetchPosterList(page: Int, size: Int) -> AnyPublisher<PosterPhotoListResponseModel, Error> {
        let url = URL(string: "\(baseURL)/api/v1/posters?page=\(page)&size=\(size)")
        return URLRequest(url: url!)
            .setHttpMethod(.GET)
            .setContentType(.json)
            .setAuthToken(token)
            .toDataTaskPublisher()
    }
    
    func fetchExerciseCategory() -> AnyPublisher<[ExerciseCategoryModel], Error> {
        let url = URL(string: "\(baseURL)/api/v1/exercises/categories")
        return URLRequest(url: url!)
            .setHttpMethod(.GET)
            .setContentType(.json)
            .toDataTaskPublisher()
    }

    func addPoster(_ requestModel: PosterAddRequestModel) -> AnyPublisher<PosterAddResponseModel, Error> {
        let boundary = "\(UUID().uuidString)"
        let url = URL(string: "\(baseURL)/api/v1/posters")
        let httpBody = NSMutableData()
        httpBody.appendString(convertFormField(named: "emotion", value: requestModel.emotion.uppercased(), using: boundary))
        let value = requestModel.categories.map { String($0) }.joined(separator: ",")
        httpBody.appendString(convertFormField(named: "categories", value: value, using: boundary))
        ["posterImage": requestModel.posterImage,
         "originImage": requestModel.originImage].forEach {
            guard let data = $0.value.pngData() else { return }
            httpBody.append(convertFileData(fieldName: $0.key, fileName: "\(Date()).png", mimeType: "image/png", fileData: data, using: boundary))
        }
        httpBody.appendString("--\(boundary)--")

        return URLRequest(url: url!)
            .setHttpMethod(.POST)
            .setContentType(.multipart(boundary: boundary))
            .setAuthToken(token)
            .setHttpBody(httpBody as Data)
            .toDataTaskPublisher()
    }

    private func convertFormField(named name: String,
                                  value: String,
                                  using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        return fieldString
    }

    private func convertFileData(fieldName: String,
                                 fileName: String,
                                 mimeType: String,
                                 fileData: Data,
                                 using boundary: String) -> Data {
        let data = NSMutableData()
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        return data as Data
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

enum NetworkError: Error {
    case unknownError
}
struct BodyMoodErrorResponse: Error, Decodable {
    let code: String
    let message: String
}

struct BodyMoodAPIResponse<Data: Decodable>: Decodable {
    let code: String
    let message: String
    let data: Data
}

struct PosterPhotoListResponseModel: Decodable, Hashable {
    let totalCount: Int
    let pageTotalCount: Int
    let pagePosition: Int
    let posters: [PosterPhotoResponseModel]
}

struct PosterPhotoResponseModel: Decodable, Hashable {
    let photoId: Int
    let imageUrl: String
    let createdAt: String
    let updatedAt: String
}

struct PosterAddResponseModel: Decodable {
    let id: Int
    let url: String
    let emotion: String
    let categories: [Int]
}

struct PosterAddRequestModel {
    let posterImage: UIImage
    let originImage: UIImage
    let emotion: String
    let categories: [Int]
}
