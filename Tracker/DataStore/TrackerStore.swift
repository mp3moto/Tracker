import Foundation

final class TrackerStore: DataStoreDelegate {
    weak var delegate: DataStoreDelegate?
    var trackerRecordStore: TrackerRecordStore?
    private var dataStore: DataStore
    var dateFromDatePicker: Date? {
        didSet {
            dataStore.dateFromDatePicker = dateFromDatePicker
        }
    }
    var searchQuery: String = ""
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
        dataStore.trackersDelegate = self
    }
    
    private func unpackSсhedule(_ packed: Int32) -> Schedule {
        Schedule(
            mon: packed & 64 == 64,
            tue: packed & 32 == 32,
            wed: packed & 16 == 16,
            thu: packed & 8 == 8,
            fri: packed & 4 == 4,
            sat: packed & 2 == 2,
            sun: packed & 1 == 1
        )
    }

    private func prepareSQLQueryString() -> String {
        let weekDayPacked = dateFromDatePicker?.getWeekDay() ?? 0
        let defaultResult = "(schedule = NULL) OR (schedule & \(weekDayPacked) != 0)"
        if searchQuery.count > 0 {
            return "(\(defaultResult)) AND title CONTAINS[c] '\(searchQuery)'"
        } else {
            searchQuery = ""
            return defaultResult
        }
    }
    
    func getTrackers() -> [Tracker] {
        guard let date = dateFromDatePicker else { return [] }
        let rawTrackers = dataStore.getRecords(className: .TrackerCoreData, sql: prepareSQLQueryString()) as [TrackerCoreData]
        var trackers: [Tracker] = []
        
        rawTrackers.forEach {
            let id = $0
            let category = $0.pinned ? LocalizedString.pinned : $0.category?.name
            var schedule: Schedule?
            if let _ = $0.schedule {
                schedule = unpackSсhedule($0.schedule as? Int32 ?? 0)
            }
            let records = trackerRecordStore?.getTrackerRecords(forTracker: id, atDate: date)
            if let category = category {
                trackers.append(
                    Tracker(
                        id: id,
                        title: $0.title ?? Const.noName,
                        emoji: $0.emoji ?? Const.emptyString,
                        color: $0.color ?? Const.defaultColor,
                        category: category,
                        schedule: schedule,
                        doneCount: records?.count ?? 0,
                        done: trackerRecordStore?.isTrackerDone(doneAt: date, trackerId: id) ?? false,
                        pinned: $0.pinned
                    )
                )
            }
        }
        
        return trackers
    }
    
    func addTracker(title: String, emoji: String, color: String, category: TrackerCategoryCoreData, schedule: Schedule?) throws {
        do {
            let newTracker = TrackerCoreData(context: dataStore.context)
            newTracker.title = title
            newTracker.emoji = emoji
            newTracker.color = color
            newTracker.pinned = false
            if let schedule = schedule {
                newTracker.schedule = (schedule.packed()) as NSNumber
            } else {
                newTracker.schedule = nil
            }
            newTracker.category = category
            try dataStore.saveRecord(object: newTracker)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func deleteTracker(tracker: TrackerCoreData) throws {
        do {
            try dataStore.deleteRecord(object: tracker)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func togglePinned(trackerId: TrackerCoreData) throws {
        do {
            let pinned = trackerId.pinned
            trackerId.pinned = !pinned
            try dataStore.saveRecord(object: trackerId)
        }
    }
    
    func didUpdate() {
        delegate?.didUpdate()
    }
}
