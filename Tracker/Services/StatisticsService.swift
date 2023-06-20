import Foundation

final class StatisticsService {
    private let trackerStore: TrackerStore
    private let trackerRecordStore: TrackerRecordStore
    
    var completedRecordsCount = 0
    
    init(trackerStore: TrackerStore, trackerRecordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
    }
    
    func trackersCompleted() -> Int {
        completedRecordsCount = trackerRecordStore.getCompletedTrackerRecordsCount(className: .TrackerRecordCoreData)
        return completedRecordsCount
    }
    
    func trackersCompletedAverage() -> Double {
        guard let firstDay = trackerRecordStore.getFirstDay(),
              let lastDay = trackerRecordStore.getLastDay()
        else { return 0 }
        let daysCount = (Calendar.current.dateComponents([.day], from: firstDay, to: lastDay).day ?? 0) + 1
        return Double(completedRecordsCount) / Double(daysCount)
    }
}
