import Foundation

final class StatisticsViewModel {
    private var model: StatisticsService
    var trackersCompleted = 0
    var trackersAverage = 0.0
    var onStatisticsRefreshed: (() -> Void)?
    
    init(model: StatisticsService) {
        self.model = model
    }
    
    func getStatistic() {
        trackersCompleted = model.trackersCompleted()
        trackersAverage = model.trackersCompletedAverage()
        onStatisticsRefreshed?()
    }
}
