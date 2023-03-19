import Foundation

final class TrackerStore: DataStoreDelegate {
    
    weak var delegate: DataStoreDelegate?
    var dataStore: DataStore
    var dateFromDatePicker: Date? {
        didSet {
            dataStore.dateFromDatePicker = dateFromDatePicker
        }
    }
    var searchQuery: String = "" {
        didSet {
            dataStore.searchQuery = searchQuery
        }
    }
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
        dataStore.trackersDelegate = self
    }
    
    func getTrackers() -> [Tracker] {
        let trackers = dataStore.trackers
        return trackers
    }
    
    func addTracker(title: String, emoji: String, color: String, category: TrackerCategoryCoreData, schedule: Schedule?) throws -> Int32 {
        do {
            let trackerId = try dataStore.addTracker(title: title, emoji: emoji, color: color, category: category, schedule: schedule)
            return trackerId
        } catch let error {
            print(error.localizedDescription)
            return 0
        }
    }
    
    func didUpdate() {
        delegate?.didUpdate()
    }
}
