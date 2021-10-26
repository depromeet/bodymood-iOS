//
//  EmotionResponse.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/26.
//

import Foundation

struct EmotionResponse: Decodable {
    let code: String
    let message: String
    let data: [EmotionDataResponse]?
}

struct EmotionDataResponse: Decodable {
    let type: String?
    let englishTitle: String?
    let koreanTitle: String?
    let startColor: String?
    let endColor: String?
    let fontColor: String?
}
