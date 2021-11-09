//
//  AuthService.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/10.
//

import Combine
import Foundation

protocol AuthServiceType {
    func kakaoLogin(accessToken: String) -> AnyPublisher<LoginResponse, Error>
    func appleLogin(accessToken: String) -> AnyPublisher<LoginResponse, Error>
    func logout() -> AnyPublisher<LogoutResponse, Error>
}

class AuthService: AuthServiceType {
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

    func logout() -> AnyPublisher<LogoutResponse, Error> {
        let url = URL(string: "\(URLConsts.baseURL)/logout")

        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let accessToken = UserDefaults.standard.string(forKey: UserDefaultKey.accessToken) ?? ""
        urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(
                type: LogoutResponse.self,
                decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
