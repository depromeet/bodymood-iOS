//
//  LogoutResponse.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/11/09.
//

import Foundation

struct LogoutResponse: Decodable {
    let code: String
    let data: String
    let message: String
}
