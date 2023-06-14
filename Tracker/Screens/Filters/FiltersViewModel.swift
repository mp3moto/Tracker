import Foundation

final class FiltersViewModel {
    private var selectedFilter: TrackersFilter
    private let filters: [TrackersFilterDescription] = [
        TrackersFilterDescription(value: .all, description: LocalizedString.trackersFilterAll),
        TrackersFilterDescription(value: .today, description: LocalizedString.trackersFilterToday),
        TrackersFilterDescription(value: .todayCompleted, description: LocalizedString.trackersFilterTodayCompleted),
        TrackersFilterDescription(value: .todayUncompleted, description: LocalizedString.trackersFilterTodayUncompleted)
    ]
    private var categoryCellViewModels: [CategoryViewModel] = []
    var onFilterSelect: ((TrackersFilter) -> Void)?
    
    init(selectedFilter: TrackersFilter) {
        self.selectedFilter = selectedFilter
        showFilters()
    }
    
    func filterTap(_ indexPath: IndexPath) {
        onFilterSelect?(filters[indexPath.row].value)
    }
    
    func showFilters() {
        var tempArray: [CategoryViewModel] = []
        
        for (index, item) in filters.enumerated() {
            tempArray.append(
                CategoryViewModel(
                    name: item.description,
                    selected: item.value == selectedFilter,
                    first: index == 0,
                    last: index == filters.count - 1
                )
            )
        }
        
        categoryCellViewModels = tempArray
    }
    
    func filtersCount() -> Int {
        filters.count
    }
    
    func getCategoryCellViewModel(at: IndexPath) -> CategoryViewModel {
        categoryCellViewModels[at.row]
    }
}
