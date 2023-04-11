import Foundation

final class CategoriesModel: DataStoreDelegate {
    var store: DataStore
    private let data: CategoryStore?
    
    init(store: DataStore) {
        self.store = store
        data = CategoryStore(dataStore: store)
        data?.delegate = self
    }
    
    func didUpdate() {
        print("didUpdate called")
    }
    
    func selectCategory(_ indexPath: IndexPath) -> TrackerCategoryCoreData? {
        guard let selectedCategory = data?.getCategory(indexPath) else { return nil }
        return selectedCategory
    }
    
    func getCategories() -> [TrackerCategoryCoreData] {
        guard let data = data else { return [] }
        return data.getCategories()
    }
    
    func deleteCategory(category: TrackerCategoryCoreData) {
        guard let data = data else { return }
        try? data.deleteCategory(category)
    }
    /*
    func categoriesCount() -> Int {
        data?.count ?? 0
    }
    */
}
