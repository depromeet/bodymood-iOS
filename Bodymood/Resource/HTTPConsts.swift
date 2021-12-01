//
//  HTTPConst.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/10.
//

import Foundation

class URLConsts {
#if DEBUG
    static let baseURL = "https://dev.bodymood.me/api/v1"
#else
    static let baseURL = "https://bodymood.me/api/v1"
#endif
}
