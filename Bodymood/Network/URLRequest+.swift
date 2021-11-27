import Foundation
import Combine

extension URLRequest {
    enum ContentType {
        case json
        case multipart(boundary: String)
    }

    enum HttpMethod: String {
        case GET, POST, DELETE
    }

    func setHttpMethod(_ method: HttpMethod) -> Self {
        var request = self
        request.httpMethod = method.rawValue
        return request
    }

    func setHttpBody(_ body: Data) -> Self {
        var request = self
        request.httpBody = body
        return request
    }

    func setAuthToken(_ token: String) -> Self {
        var request = self
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func setContentType(_ contentType: ContentType) -> Self {
        var request = self
        let value: String
        switch contentType {
        case .json: value = "application/json"
        case .multipart(let boundary):
            value = "multipart/form-data; boundary=\(boundary)"
        }
        request.setValue(value, forHTTPHeaderField: "Content-Type")
        return request
    }

    func toDataTaskPublisher<Response: Decodable>() -> AnyPublisher<Response, Error> {
        URLSession.shared.dataTaskPublisher(for: self)
            .tryMap { data, response in
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    throw NetworkError.unknownError
                }

                if statusCode == 401 {
                    throw NetworkError.tokenError
                }

                guard (200..<300).contains(statusCode) else {
                    let errorResponse = try? JSONDecoder().decode(BodyMoodErrorResponse.self, from: data)
                    throw errorResponse ?? NetworkError.unknownError
                }

                return data
            }.decode(type: BodyMoodAPIResponse<Response>.self, decoder: JSONDecoder())
            .map(\.data)
            .eraseToAnyPublisher()
    }
}
