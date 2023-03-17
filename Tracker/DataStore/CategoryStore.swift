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
    
    func getCategory(_ id: Int32) -> Category? {
        do {
            return try dataStore.getCategory(id)
        } catch {
            return nil
        }
    }
    
    func getFRCSections() -> [String] {
        dataStore.getFRCSections()
    }
    
    func getCategoryNameById(id: Int32) -> String? {
        return getCategory(id)?.name
    }
    
    func getCategoryEntity(id: Int32) -> TrackerCategoryCoreData? {
        do {
            let entity = try dataStore.getCategoryEntity(id)
            return entity
        } catch {
            return nil
        }
    }
    
    func updateCategory(id: Int, name: String) {
        do {
            return try dataStore.updateCategory(id: id, name: name)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func addCategory(name: String) throws -> Int32 {
        do {
            return try dataStore.addCategory(name: name)
        } catch {
            print("catch in action in CategoryStore")
            return 0
        }
    }
    
    func deleteCategory(_ id: Int32) {
        do {
            try dataStore.deleteCategory(id)
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
