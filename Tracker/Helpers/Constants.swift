import Foundation

struct Const {
    static let modelName = "DataModel"
    static let noName = "Без названия"
    static let emptyString = ""
    static let defaultColor = "Sunset Orange"
    static let trackerNameLengthLimit = 38
    static let habit = "habit"
    static let event = "event"
    
    static let appMetricaApiKey = "915437ea-6f5a-4ce2-95af-7b25c46792c2"
    static let analyticsIdentifierForAddButton = "add_track"
    static let analyticsIdentifierForTracker = "track"
    static let analyticsIdentifierForFilterButton = "filter"
    static let analyticsIdentifierForTrackerContextMenuEdit = "edit"
    static let analyticsIdentifierForTrackerContextMenuDelete = "delete"
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
    static let pinned = NSLocalizedString("pinned", comment: "")
    static let deleteTrackerConfirmation = NSLocalizedString("deleteTrackerConfirmation", comment: "")
    static let editTracker = NSLocalizedString("editTracker", comment: "")
    static let save = NSLocalizedString("save", comment: "")
    static let filters = NSLocalizedString("filters", comment: "")
    static let trackersFilterAll = NSLocalizedString("trackersFilterAll", comment: "")
    static let trackersFilterToday = NSLocalizedString("trackersFilterToday", comment: "")
    static let trackersFilterTodayCompleted = NSLocalizedString("trackersFilterTodayCompleted", comment: "")
    static let trackersFilterTodayUncompleted = NSLocalizedString("trackersFilterTodayUncompleted", comment: "")
    static let nothingToAnalyze = NSLocalizedString("nothingToAnalyze", comment: "")
    static let statisticsAverage = NSLocalizedString("statisticsAverage", comment: "")
    static let statisticsBestPeriod = NSLocalizedString("statisticsBestPeriod", comment: "")
    static let statisticsBestDays = NSLocalizedString("statisticsBestDays", comment: "")
}
