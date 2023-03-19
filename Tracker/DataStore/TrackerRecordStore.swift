import Foundation

final class TrackerRecordStore: DataStoreDelegate {
    
    weak var delegate: DataStoreDelegate?
    var dataStore: DataStore
    
    private let dateFormatter = DateFormatter()
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
        dataStore.trackerRecordDelegate = self
    }
    
    func toggleTrackerRecord(atDate: Date, trackerId: Int32) throws {
        do {
            isTrackerDone(atDate: atDate, trackerId: trackerId) ? try deleteTrackerDone(atDate: atDate, trackerId: trackerId) : try addTrackerRecord(doneAt: atDate, trackerId: trackerId)
            didUpdate()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func addTrackerRecord(doneAt: Date, trackerId: Int32) throws {
        do {
            try dataStore.addTrackerRecord(doneAt: doneAt, trackerId: Int32(trackerId))
            delegate?.didUpdate()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func deleteTrackerDone(atDate: Date, trackerId: Int32) throws {
        do {
            try dataStore.deleteTrackerDone(atDate: atDate, trackerId: trackerId)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func isTrackerDone(atDate: Date, trackerId: Int32) -> Bool {
        dataStore.isTrackerDone(atDate: atDate, trackerId: trackerId)
    }
    
    func didUpdate() {
        delegate?.didUpdate()
    }
}
