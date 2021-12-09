//
//  HackleTracker.swift
//  Bodymood
//
//  Created by 허예은 on 2021/12/05.
//

import Foundation

import Hackle

class HackleTracker {
    enum PageType: String {
        case login = "Login"
        case posterList = "PosterList"
        case posterDetail = "PostDetail"
        case posterTemplate = "PosterTemplate"
        case posterEdit = "PosterEdit"
        case camera = "Camera"
        case photoAlbum = "PhotoAlbum"
        case exerciseCategory = "ExerciseCategory"
        case emotion = "Emotion"
        case mypage = "Mypage"
        case logout = "Logout"
        case agreement = "Agreement"
        case removeAccount = "RemoveAccount"
    }
    
    enum EventType: String {
        case click = "Click"
        case viewWillAppear = "ViewWillAppear"
    }
    
    enum ButtonType: String {
        case kakaoTalkButton = "KakaoTalkButton"
        case kakaoAccountButton = "KakaoAccountButton"
        case appleButton = "AppleButton"
        case posterCompleteButton = "PosterCompleteButton"
        case posterDetailButton = "PosterDetailButton"
        case deleteButton = "DeleteButton"
        case deleteConfirmButton = "DeleteConfirmButton"
        case deleteCancelButton = "DeleteCancelButton"
        case shareButton = "ShareButton"
        case homeButton = "HomeButton"
        case logoutConfirmButton = "LogoutConfirmButton"
        case logoutCancelButton = "LogoutCancelButton"
        case removeAccountConfirmButton = "RemoveAccountConfirmButton"
        case removeAccountCancelButton = "RemoveAccountCancelButton"
    }
    
    static func track(key: String, pageName: PageType, eventType: EventType) {
        let event = Hackle.event(key: key, properties: ["page_name": pageName.rawValue, "event_type": eventType.rawValue])
        Hackle.app()?.track(event: event)
    }
    
    static func track(key: String, pageName: PageType, eventType: EventType, object: ButtonType) {
        let event = Hackle.event(key: key, properties: ["page_name": pageName.rawValue, "event_type": eventType.rawValue, "object": object.rawValue])
        Hackle.app()?.track(event: event)
    }
}
