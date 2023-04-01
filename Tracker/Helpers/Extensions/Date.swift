import Foundation

extension Date {
    func prepareDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let shortDate = dateFormatter.string(from: self)
        let longDate = "\(shortDate)T00:00:00+0000"
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let result = dateFormatter.date(from: longDate) {
            return result
        } else {
            return nil
        }
    }
    func getWeekDay() -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let weekDay = calendar.component(.weekday, from: self)
        switch weekDay {
        case 1: return 1
        case 2: return 2
        case 3: return 4
        case 4: return 8
        case 5: return 16
        case 6: return 32
        case 7: return 64
        default: return 0
        }
    }
}
