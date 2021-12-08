//
//  Bodymood++Bundle.swift
//  Bodymood
//
//  Created by 허예은 on 2021/12/08.
//

import Foundation

extension Bundle {
    var kakaoAPIKey: String {
        guard let filePath = self.path(forResource: "BodymoodInfo", ofType: "plist") else {
            fatalError("파일 경로가 존재하지 않습니다.")
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        
        guard let value = plist?.object(forKey: "KAKAO_API_KEY") as? String else {
            fatalError("카카오 API Key를 성공적으로 불러오지 못하였습니다.")
        }
        return value
    }
    
    var hackleAPIKey: String {
        guard let filePath = self.path(forResource: "BodymoodInfo", ofType: "plist") else {
            fatalError("파일 경로가 존재하지 않습니다.")
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        
        guard let value = plist?.object(forKey: "HACKLE_API_KEY") as? String else {
            fatalError("핵클 API Key를 성공적으로 불러오지 못하였습니다.")
        }
        return value
    }
}
