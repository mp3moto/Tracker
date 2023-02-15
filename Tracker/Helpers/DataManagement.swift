import Foundation

final class DataManagement {
    
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case categories
        case trackers
    }
    var categories: [Category]? {
        get {
            if let data = userDefaults.data(forKey: Keys.categories.rawValue) {
                if let categories = try? PropertyListDecoder().decode([Category].self, from: data) {
                    return categories
                } else { return nil }
            } else { return nil }
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
    
    var trackers: [Tracker]? {
        get {
            if let data = userDefaults.data(forKey: Keys.trackers.rawValue) {
                if let trackers = try? PropertyListDecoder().decode([Tracker].self, from: data) {
                    return trackers
                } else { return nil }
            } else { return nil }
        }
        set {
            if newValue != nil {
                if let data = try? PropertyListEncoder().encode(newValue) {
                    userDefaults.set(data, forKey: Keys.trackers.rawValue)
                }
            }
            else {
                userDefaults.removeObject(forKey: Keys.trackers.rawValue)
            }
        }
    }
    
    func count(for entity: String) -> Int {
        switch entity {
        case "category": return categories?.count ?? 0
        case "tracker": return trackers?.count ?? 0
        default: return 0
        }
    }
    
    func addCategory(name: String) -> Int {
        let id = getNextId(for: "category")
        if categories == nil {
            categories = []
        }
        categories?.append(Category(id: id, name: name))
        return id
    }
    
    func addTracker(title: String, emoji: String, color: String, categoryId: Int, schedule: Schedule?) -> Int {
        let id = getNextId(for: "tracker")
        if trackers == nil {
            trackers = []
        }
        
        trackers?.append(Tracker(id: id, title: title, emoji: emoji, color: color, categoryId: categoryId, schedule: schedule))
        return id
    }
    
    func updateCategory(id: Int, name: String) {
        if let index = categories?.firstIndex(where: { $0.id == id }) {
            categories?[index] = Category(id: id, name: name)
        }
    }
    
    func getNextId(for entity: String) -> Int {
        var maxId: Int?
        switch entity {
        case "category": maxId = categories?.max(by: { a, b in a.id < b.id })?.id
        case "tracker": maxId = trackers?.max(by: { a, b in a.id < b.id })?.id
        default: maxId = 0
        }
        if let maxId = maxId {
            let nextId = maxId + 1
            guard nextId > 0 else { return 1 }
            return nextId
        } else {
            return 1
        }
    }
    
    func getCategoryNameById(id: Int) -> String? {
        if let index = categories?.firstIndex(where: { $0.id == id }) {
            return categories?[index].name
        } else {
            return nil
        }
        
    }
}
