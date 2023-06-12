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

struct LocalizedString {
    static let onboardingPage01Text = NSLocalizedString("onboardingPage01Text", comment: "")
    static let onboardingPage02Text = NSLocalizedString("onboardingPage02Text", comment: "")
    static let onboardingButtonText = NSLocalizedString("onboardingButtonText", comment: "")
    static let schedule = NSLocalizedString("schedule", comment: "")
    static let color = NSLocalizedString("color", comment: "")
    static let daysOfWeek = [
        NSLocalizedString("mon", comment: ""),
        NSLocalizedString("tue", comment: ""),
        NSLocalizedString("wed", comment: ""),
        NSLocalizedString("thu", comment: ""),
        NSLocalizedString("fri", comment: ""),
        NSLocalizedString("sat", comment: ""),
        NSLocalizedString("sun", comment: "")
    ]
    static let done = NSLocalizedString("done", comment: "")
    static let edit = NSLocalizedString("edit", comment: "")
    static let delete = NSLocalizedString("delete", comment: "")
    static let enterCategoryName = NSLocalizedString("enterCategoryName", comment: "")
    static let newCategory = NSLocalizedString("newCategory", comment: "")
    static let category = NSLocalizedString("category", comment: "")
    static let addCategory = NSLocalizedString("addCategory", comment: "")
    static let editCategory = NSLocalizedString("editCategory", comment: "")
    static let categoriesPlaceholder = NSLocalizedString("categoriesPlaceholder", comment: "")
    static let newHabit = NSLocalizedString("newHabit", comment: "")
    static let newEvent = NSLocalizedString("newEvent", comment: "")
    static let cancel = NSLocalizedString("cancel", comment: "")
    static let create = NSLocalizedString("create", comment: "")
    static let trackerNameLimitReached = NSLocalizedString("trackerNameLimitReached", comment: "")
    static let enterTrackerName = NSLocalizedString("enterTrackerName", comment: "")
    static let whatWillWeTrack = NSLocalizedString("whatWillWeTrack", comment: "")
    static let nothingFound = NSLocalizedString("nothingFound", comment: "")
    static let trackers = NSLocalizedString("trackers", comment: "")
    static let search = NSLocalizedString("search", comment: "")
    static let statistics = NSLocalizedString("statistics", comment: "")
    static let habit = NSLocalizedString("habit", comment: "")
    static let event = NSLocalizedString("event", comment: "")
    static let newTracker = NSLocalizedString("newTracker", comment: "")
    static let pin = NSLocalizedString("pin", comment: "")
    static let unpin = NSLocalizedString("unpin", comment: "")
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
