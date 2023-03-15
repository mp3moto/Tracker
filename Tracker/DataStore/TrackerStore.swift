import Foundation

final class TrackerStore: DataStoreDelegate {
    
    weak var delegate: DataStoreDelegate?
    var dataStore: DataStore
    var dateFromDatePicker: Date? {
        didSet {
            dataStore.dateFromDatePicker = dateFromDatePicker
        }
    }
    
    
    func getTrackers() -> [Tracker] {
        let trackers = dataStore.trackers
        return trackers
    }
    
    func addTracker(title: String, emoji: String, color: String, categoryId: Int32, schedule: Schedule?) throws -> Int32 {
        do {
            let trackerId = try dataStore.addTracker(title: title, emoji: emoji, color: color, categoryId: categoryId, schedule: schedule)
            return trackerId
        } catch let error {
            print(error.localizedDescription)
            return 0
        }
    }
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
        dataStore.trackersDelegate = self
    }
    
    func numberOfSectionsForTrackers() -> Int {
        dataStore.numberOfSectionsForTrackers()
        //trackersFRC.sections?.count ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCoreData? {
        dataStore.trackerObject(at: indexPath)
    }
    
    func numberOfRowsInSectionForTrackers(_ section: Int) -> Int {
        dataStore.numberOfRowsInSectionForTrackers(section)
    }
    
    func didUpdate() {
        delegate?.didUpdate()
    }
}
