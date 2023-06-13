import Foundation

final class CategoryStore {
    private var dataStore: DataStore
    private var count: Int = 0
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
    }
    
    func getCategories() -> [TrackerCategoryCoreData] {
        let categories = dataStore.getRecords(className: .TrackerCategoryCoreData) as [TrackerCategoryCoreData]
        return categories
    }
    
    
    func getCategoryStruct(_ id: TrackerCategoryCoreData) -> Category? {
        return Category(name: id.name ?? Const.noName)
    }
    
    func getCategory(_ indexPath: IndexPath) -> TrackerCategoryCoreData? {
        let categories = dataStore.getRecords(className: .TrackerCategoryCoreData)
        if indexPath.row < categories.count {
            return categories[indexPath.row] as? TrackerCategoryCoreData
        } else {
            return nil
        }
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
}
