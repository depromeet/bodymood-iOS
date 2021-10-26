//
//  EmotionService.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/26.
//

import Combine
import Foundation

protocol EmotionServiceType {
    func emotionCategories() -> AnyPublisher<EmotionResponse, Error>
}

class EmotionService: EmotionServiceType {
    func emotionCategories() -> AnyPublisher<EmotionResponse, Error> {
        let url = URL(string: "\(URLConsts.baseURL)/emotions/categories")

        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

//        let httpBody = try? JSONSerialization.data(withJSONObject: [], options: [])
//
//        urlRequest.httpBody = httpBody
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(
                type: EmotionResponse.self,
                decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
