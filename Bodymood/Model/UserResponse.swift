//
//  UserResponse.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/11/08.
//

import Foundation

struct UserResponse: Decodable {
    let code: String
    let message: String
    let data: UserDataResponse
}

struct UserDataResponse: Decodable {
    let socialProvider: String
    let name: String
    let profileUrl: String?
}
