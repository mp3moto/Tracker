import Foundation

final class CategoryStore: DataStoreDelegate {
    
    weak var delegate: DataStoreDelegate?
    var dataStore: DataStore
    var count: Int = 0
    var searchQuery: String = ""
    /*var dateFromDatePicker: Date? {
        didSet {
            dataStore.dateFromDatePicker = dateFromDatePicker
        }
    }*/
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
        dataStore.categoriesDelegate = self
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
    /*
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
    */
   /*
    func prepareSQLQueryString() -> String {
        let defaultResult = "(trackers.schedule > \(getWeekDay())) OR (trackers.schedule = NULL)"
        if searchQuery.count > 0 {
            return "(\(defaultResult)) AND trackers.title CONTAINS[c] '\(searchQuery)'"
        } else {
            searchQuery = ""
            return defaultResult
        }
    }
    */
    
    func getCategories() -> [Category] {
        let categories = dataStore.getRecords(className: .TrackerCategoryCoreData) as [TrackerCategoryCoreData]
        count = categories.count
        var result: [Category] = []
        categories.forEach {
            result.append(Category(name: $0.name ?? Const.noName))
        }
        return result
    }
    
    func getCategory(_ id: TrackerCategoryCoreData) -> Category? {
        return Category(/*id: id, */name: id.name ?? Const.noName)
    }
    
    func updateCategory(id: TrackerCategoryCoreData, name: String) throws {
        do {
            id.name = name
            try dataStore.saveRecord(object: id)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func addCategory(name: String) throws {
        do {
            let newCategory = TrackerCategoryCoreData(context: dataStore.context)
            newCategory.name = name
            try dataStore.saveRecord(object: newCategory)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func deleteCategory(_ id: TrackerCategoryCoreData) throws {
        do {
            try dataStore.deleteRecord(object: id)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func numberOfRowsInSectionForCategories(_ section: Int) -> Int {
        dataStore.numberOfRowsInSectionForCategories(section)
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        dataStore.categoryObject(at: indexPath)
    }
    
    func didUpdate() {
        delegate?.didUpdate()
    }
}
