import Foundation

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        formatter.timeZone = NSTimeZone.local
        return formatter.string(from: self)
    }
    
    static func fromISO8601(_ dateString: String, withFractionalSeconds: Bool) -> Date? {
        let formatter = ISO8601DateFormatter()
        if withFractionalSeconds {
            formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        }
        return formatter.date(from: dateString)
    }
}
