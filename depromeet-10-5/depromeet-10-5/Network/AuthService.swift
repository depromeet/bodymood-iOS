//
//  AuthService.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/10.
//

import Combine
import Foundation

//enum KakaoAuthError: Error {
//    case statusCode
//    case unauthorized
//    case forbidden
//    case notFound
//    case other(Error)
//
//    static func map(_ error: Error) -> KakaoAuthError {
//        return (error as? KakaoAuthError) ?? .other(error)
//    }
//}

protocol AuthServiceProtocol {

}

struct AuthService: AuthServiceProtocol {
    func kakaoAuth(accessToken: String) -> AnyPublisher<KakaoLoginResponse, Error> {

        let url = URL(string: "\(URLConsts.baseURL)/auth/kakao")

        let parameters = ["accessToken": accessToken]

        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])


        urlRequest.httpBody = httpBody
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(
                type: KakaoLoginResponse.self,
                decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
        
//        return URLSession.shared
//            .dataTaskPublisher(for: urlRequest)
//            .tryMap { response -> Data in
//                guard let httpURLResponse = response.response as? HTTPURLResponse,
//                      httpURLResponse.statusCode == 200 else {
//                          throw KakaoAuthError.statusCode
//                      }
//                return response.data
//            }
//            .decode(
//                type: KakaoLoginResponse.self,
//                decoder: JSONDecoder())
//            .mapError { KakaoAuthError.map($0) }
//            .eraseToAnyPublisher()

//        return URLSession.shar14ed
//            .dataTaskPublisher(for: urlRequest)
//            .map { $0.data }
//            .decode(
//                type: KakaoLoginResponse.self,
//                decoder: JSONDecoder())
//            .sink(
//                receiveCompletion: { completion in
//                    if case .failure(let error) = completion {
//                        Log.debug(error)
//                    }
//                }, receiveValue: { object in
//                    Log.debug("\(object.code), \(object.data)")
//                })
    }
}
