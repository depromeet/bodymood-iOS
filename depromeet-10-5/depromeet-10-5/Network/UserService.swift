//
//  UserService.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/11/08.
//

import Combine
import Foundation

protocol UserServiceType {
    func userInfo() -> AnyPublisher<UserResponse, Error>
}

class UserService: UserServiceType {
    func userInfo() -> AnyPublisher<UserResponse, Error> {
        let url = URL(string: "\(URLConsts.baseURL)/user/me")

        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let accessToken = UserDefaults.standard.string(forKey: UserDefaultKey.accessToken)!
        urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(
                type: UserResponse.self,
                decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
