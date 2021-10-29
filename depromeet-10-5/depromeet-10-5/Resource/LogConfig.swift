//
//  LogConfig.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/01.
//

import Foundation

public struct Log {
    
    public static func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
            let output = items.map { "\($0)" }.joined(separator: separator)
            print("🗣 [\(getCurrentTime())] Log - \(output)", terminator: terminator)
        #else
            print("🗣 [\(getCurrentTime())] Log - RELEASE MODE")
        #endif
    }
    
    public static func warning(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
            let output = items.map { "\($0)" }.joined(separator: separator)
            print("⚡️ [\(getCurrentTime())] Log - \(output)", terminator: terminator)
        #else
            print("⚡️ [\(getCurrentTime())] Log - RELEASE MODE")
        #endif
    }
    
    public static func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
            let output = items.map { "\($0)" }.joined(separator: separator)
            print("🚨 [\(getCurrentTime())] Log - \(output)", terminator: terminator)
        #else
            print("🚨 [\(getCurrentTime())] Log - RELEASE MODE")
        #endif
    }
    
    fileprivate static func getCurrentTime() -> String {
        let now = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return dateFormatter.string(from: now as Date)
    }
}
