import Foundation

final class TrackerRecordStore: DataStoreDelegate {
    
    weak var delegate: DataStoreDelegate?
    var dataStore: DataStore
    
    private let dateFormatter = DateFormatter()
    
    func addTrackerRecord(doneAt: Date, trackerId: Int) throws {
        do {
            try dataStore.addTrackerRecord(doneAt: doneAt, trackerId: Int32(trackerId))
            delegate?.didUpdate()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func deleteTrackerDone(onDate: Date, trackerId: Int) throws {
        do {
            try dataStore.deleteTrackerDone(atDate: onDate, trackerId: trackerId)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func isTrackerDone(atDate: Date, trackerId: Int32) -> Bool {
        dataStore.isTrackerDone(atDate: atDate, trackerId: trackerId)
    }
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
        dataStore.trackerRecordDelegate = self
    }
    
    func didUpdate() {
        delegate?.didUpdate()
    }
}
