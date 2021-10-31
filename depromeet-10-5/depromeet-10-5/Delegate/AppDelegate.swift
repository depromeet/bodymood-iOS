//
//  AppDelegate.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/09/12.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import AuthenticationServices

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
        KakaoSDKCommon.initSDK(appKey: "1f1d9175f9c1e2682cf32d234475f94a") // initialize Kakao SDK
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: UserDefaults.standard.string(forKey: UserDefaultKey.appleID) ?? "", completion: { credentialState, error in
            switch credentialState {
            case .authorized:
                Log.debug("애플로그인 연동 완료")
            case .revoked:
                Log.debug("애플로그인 연동 상태 X")
            case .notFound:
                Log.debug("해당 ID를 찾을 수 없습니다")
            default:
                break
            }
        })
        
        NotificationCenter.default.addObserver(forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil, queue: nil) { notification in
            Log.debug("Revoked Notification")
            // 로그인 페이지 이동
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if(AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }

        return false
    }
}
