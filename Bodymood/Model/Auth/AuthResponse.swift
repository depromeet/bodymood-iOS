//
//  KakaoLoginResponse.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/10.
//

import Foundation

struct AuthResponse: Decodable {
    let code: String
    let data: AuthDataResponse?
    let message: String
}

struct AuthDataResponse: Decodable {
    let accessToken: String?
    let refreshToken: String?
}
