import Foundation

final class CategoryStore: DataStoreDelegate {
    
    weak var delegate: DataStoreDelegate?
    var dataStore: DataStore
    var count: Int = 0
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
        dataStore.categoriesDelegate = self
    }
    
    func getCategories() -> [Category] {
        let categories = dataStore.categories
        count = categories.count
        return categories
    }
    
    
    func getCategory(_ id: TrackerCategoryCoreData) -> Category? {
        return Category(name: id.name ?? Const.noName)
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
