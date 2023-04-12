import Foundation

struct Const {
    static let modelName = "DataModel"
    static let noName = "Без названия"
    static let emptyString = ""
    static let defaultColor = "Sunset Orange"
    static let trackerNameLengthLimit = 38
    static let habit = "habit"
    static let event = "event"
}

enum CoreDataClasses: String {
    case TrackerCoreData
    case TrackerCategoryCoreData
    case TrackerRecordCoreData
}

enum TrackerType: String {
    case habit
    case event
}

