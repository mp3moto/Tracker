import Foundation

/*
«Лучший период» — это максимальное количество дней без перерыва по всем трекерам.
 
«Идеальные дни» — это дни, когда были выполнены все запланированные привычки.
 1. Выбрать даты, когда были отмечены трекеры и сразу определить их день недели и количество выполненных трекеров в эту дату
 2. Узнать количество трекеров на каждый день недели
 3. Сравнить и сложить
 
«Среднее значение» — это среднее количество привычек, выполненных за 1 день.
 берем первый и последний день отмеченных трекеров
 складываем количество
 делим на количество дней
 
*/

final class StatisticsService {
    private let trackerStore: TrackerStore
    private let trackerRecordStore: TrackerRecordStore
    
    var completedRecordsCount = 0 {
        didSet {
            print("completedRecordsCount set to \(completedRecordsCount)")
        }
    }
    
    init(trackerStore: TrackerStore, trackerRecordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
    }
    
    func trackersCompleted() -> Int {
        completedRecordsCount = trackerRecordStore.getCompletedTrackerRecordsCount(className: .TrackerRecordCoreData)
        return completedRecordsCount
    }
    
    func trackersCompletedAverage() -> Double {
        print("completedRecordsCount in trackersCompletedAverage = \(completedRecordsCount)")
        guard let firstDay = trackerRecordStore.getFirstDay(),
              let lastDay = trackerRecordStore.getLastDay()
        else { return 0 }
        let daysCount = (Calendar.current.dateComponents([.day], from: firstDay, to: lastDay).day ?? 0) + 1
        return Double(completedRecordsCount) / Double(daysCount)
    }
    /*
    func trackersPerfectDays() -> Int {
        let records = trackerRecordStore.getCompletedTrackerRecords()
        
    }
     */
}
