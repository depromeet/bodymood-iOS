//
//  UserDefaultKey.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/17.
//

import Foundation

struct UserDefaultKey {
    static let accessToken: String = "accessToken"
    static let refreshToken: String = "refreshToken"
    static let userName: String = "userName"
    static let appleID: String = "appleID"
    static let socialProvider: String = "socialProvider"
    
    static var keys = [
        accessToken, refreshToken, userName, appleID, socialProvider
    ]
}
