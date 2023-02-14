import Foundation

final class DataManagement {
    
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case categories
    }
    var categories: [Category]? {
        get {
            if let data = userDefaults.data(forKey: Keys.categories.rawValue) {
                if let categories = try? PropertyListDecoder().decode([Category].self, from: data) {
                    return categories
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                if let data = try? PropertyListEncoder().encode(newValue) {
                    userDefaults.set(data, forKey: Keys.categories.rawValue)
                }
            }
            else {
                userDefaults.removeObject(forKey: Keys.categories.rawValue)
            }
        }
    }
    
    func categoriesCount() -> Int {
        return categories?.count ?? 0
    }
    
    func addCategory(name: String) -> Int {
        let id = getNextId()
        print("id = \(id)")
        if categories == nil {
            categories = []
        }
        categories?.append(Category(id: id, name: name))
        return id
    }
    
    func updateCategory(id: Int, name: String) {
        //print("id = \(id) name = \(name)")
        if let index = categories?.firstIndex(where: { $0.id == id }) {
            categories?[index] = Category(id: id, name: name)
        }
    }
    
    func getNextId() -> Int {
        if let maxId = categories?.max(by: { a, b in a.id < b.id })?.id {
            let nextId = maxId + 1
            guard nextId > 0 else { return 1 }
            return nextId
        } else {
            return 1
        }
    }
    
}
