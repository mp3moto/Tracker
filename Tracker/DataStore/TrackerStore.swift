import Foundation

final class TrackerStore: DataStoreDelegate {
    
    weak var delegate: DataStoreDelegate?
    var dataStore: DataStore
    var dateFromDatePicker: Date? {
        didSet {
            dataStore.dateFromDatePicker = dateFromDatePicker
        }
    }
    var searchQuery: String = ""/* {
        didSet {
            dataStore.searchQuery = searchQuery
        }
    }*/
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
        dataStore.trackersDelegate = self
    }
    
    func unpackSсhedule(_ packed: Int32) -> Schedule {
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
    
    private func getWeekDay() -> Int {
        guard let currentDate = dateFromDatePicker else { return 0 }
        let calendar = Calendar(identifier: .gregorian)
        let weekDay = calendar.component(.weekday, from: currentDate)
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
    
    func prepareSQLQueryString() -> String {
        let defaultResult = "(schedule & \(getWeekDay()) != 0) OR (schedule = NULL)"
        if searchQuery.count > 0 {
            return "(\(defaultResult)) AND title CONTAINS[c] '\(searchQuery)'"
        } else {
            searchQuery = ""
            return defaultResult
        }
    }
    
    func getTrackers() -> [Tracker] {
        let rawTrackers = dataStore.getRecords(className: .TrackerCoreData, sql: prepareSQLQueryString()) as [TrackerCoreData]
        var trackers: [Tracker] = []
        
        rawTrackers.forEach {
            let category = $0.category?.name
            var schedule: Schedule?
            if let _ = $0.schedule {
                schedule = unpackSсhedule($0.schedule as? Int32 ?? 0)
            }
            if let category = category {
                trackers.append(
                    Tracker(
                        //id: trackerId,
                        title: $0.title ?? Const.noName,
                        emoji: $0.emoji ?? Const.emptyString,
                        color: $0.color ?? Const.defaultColor,
                        category: category,
                        schedule: schedule,
                        doneCount: 0,/*fetchedDoneData.filter { $0.tracker?.id == trackerId }.count,*/
                        done: false/*fetchedDoneData.filter { $0.doneAt == dateFromDatePicker && $0.tracker?.id == trackerId }.count > 0*/
                    )
                )
            }
        }
        
        //dataStore.getRecords(class: .TrackerCoreData)
        //let trackers = dataStore.trackers
        return trackers
    }
    
    func addTracker(title: String, emoji: String, color: String, category: TrackerCategoryCoreData, schedule: Schedule?) throws {
        do {
            let newTracker = TrackerCoreData(context: dataStore.context)
            newTracker.title = title
            newTracker.emoji = emoji
            newTracker.color = color
            if let schedule = schedule {
                newTracker.schedule = (schedule.packed()) as NSNumber
            } else {
                newTracker.schedule = nil
                dataStore.safeMode = true
            }
            newTracker.category = category
            try dataStore.saveRecord(object: newTracker)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func didUpdate() {
        delegate?.didUpdate()
    }
}
