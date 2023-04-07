import Foundation

final class TrackerRecordStore: DataStoreDelegate {
    
    weak var delegate: DataStoreDelegate?
    var dataStore: DataStore
    
    private let dateFormatter = DateFormatter()
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
        dataStore.trackerRecordDelegate = self
    }
    
    func getTrackerRecordFor(trackerId: TrackerCoreData, doneAt: Date) -> TrackerRecordCoreData? {
        let sql = "doneAt = %@"
        let doneAt = doneAt as NSDate
        guard let fetchedDoneData = dataStore.getRecords(className: .TrackerRecordCoreData, sql: sql, additionalParam: doneAt) as? [TrackerRecordCoreData],
              fetchedDoneData.count > 0
        else { return nil }
        
        return fetchedDoneData.filter { $0.tracker == trackerId }.first
    }
    
    func getTrackerRecords(forTracker: TrackerCoreData, atDate: Date) -> [TrackerRecord] {
        let sql = "doneAt <= %@"
        guard let atDate = atDate.prepareDate() as? NSDate,
              let fetchedDoneData = dataStore.getRecords(className: .TrackerRecordCoreData, sql: sql, additionalParam: atDate) as? [TrackerRecordCoreData]
        else { return [] }
        var result: [TrackerRecord] = []
        fetchedDoneData.forEach {
            if forTracker == $0.tracker {
                result.append(TrackerRecord(trackerId: forTracker, doneAt: $0.doneAt ?? Date()))
            }
        }
        print(result)
        return result
    }
    
    func toggleTrackerRecord(doneAt: Date, trackerId: TrackerCoreData) throws {
        do {
            isTrackerDone(doneAt: doneAt, trackerId: trackerId) ? try deleteTrackerRecord(doneAt: doneAt, trackerId: trackerId) : try addTrackerRecord(doneAt: doneAt, trackerId: trackerId)
            didUpdate()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func addTrackerRecord(doneAt: Date, trackerId: TrackerCoreData) throws {
        do {
            let newTrackerRecord = TrackerRecordCoreData(context: dataStore.context)
            newTrackerRecord.tracker = trackerId
            newTrackerRecord.doneAt = doneAt
            try dataStore.saveRecord(object: newTrackerRecord)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func deleteTrackerRecord(doneAt: Date, trackerId: TrackerCoreData) throws {
        guard let trackerRecord = getTrackerRecordFor(trackerId: trackerId, doneAt: doneAt) else { return }
        do {
            try dataStore.deleteRecord(object: trackerRecord)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func isTrackerDone(doneAt: Date, trackerId: TrackerCoreData) -> Bool {
        getTrackerRecordFor(trackerId: trackerId, doneAt: doneAt) != nil ? true : false
    }
    
    func didUpdate() {
        delegate?.didUpdate()
    }
}
