//
//  AuthService.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/10.
//

import Combine
import Foundation

struct AuthService {
    func kakaoLogin(accessToken: String) -> AnyPublisher<LoginResponse, Error> {
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
                    type: LoginResponse.self,
                    decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
    }

    func appleLogin(accessToken: String) -> AnyPublisher<LoginResponse, Error> {
        let url = URL(string: "\(URLConsts.baseURL)/auth/apple")
        let parameters = ["accessToken": accessToken]

        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        urlRequest.httpBody = httpBody
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(
                type: LoginResponse.self,
                decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
