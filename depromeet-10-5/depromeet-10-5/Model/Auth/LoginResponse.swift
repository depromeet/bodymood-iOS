//
//  KakaoLoginResponse.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/10.
//

import Foundation

struct LoginResponse: Decodable {
    let code: String
    let data: AuthResponse?
    let message: String
}

struct AuthResponse: Decodable {
    let accessToken: String?
    let refreshToken: String?
}
