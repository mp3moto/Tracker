import UIKit
import CoreData

final class DataManagement: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case categories
        case trackers
    }
    
    private lazy var fetchResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()
        
        return fetchResultsController
    }()
    
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    
    //weak var delegate: DataManagementDelegate?
    /*
    var categories: [Category] {
        get {
            let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
            var categories: [Category] = []
            do {
                let fetchedData = try context.fetch(request)
                fetchedData.forEach {
                    categories.append(Category(id: $0.id, name: $0.name ?? const.noName))
                }
            } catch let error {
                print(error.localizedDescription)
            }
            return categories
        }
    }
    */
    var trackers: [Tracker] {
        get {
            if let data = userDefaults.data(forKey: Keys.trackers.rawValue) {
                if let trackers = try? PropertyListDecoder().decode([Tracker].self, from: data) {
                    return trackers
                } else { return [] }
            } else { return [] }
        }
        set {
            if let data = try? PropertyListEncoder().encode(newValue) {
                userDefaults.set(data, forKey: Keys.trackers.rawValue)
            }
        }
    }
    
    convenience override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.init(context: appDelegate.persistentContainer.viewContext)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func count(for entity: String) -> Int {
        switch entity {
        //case "category": return categories.count
        case "tracker": return trackers.count
        default: return 0
        }
    }
    
    func addCategory(name: String) throws -> Int32 {
        let id = getNextId(for: "category")
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.id = id
        newCategory.name = name

        try context.save()

        return id
    }
    
    func deleteCategory(_ id: Int32) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(id)")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            guard let fetchedResults = try context.fetch(fetchRequest) as? [NSManagedObject] else { return }
            for record in fetchedResults {
                context.delete(record)
            }
            try context.save()
        } catch {
            print("An error occured while deleting category with id \(id)")
        }
    }
    
    func addTracker(title: String, emoji: String, color: String, categoryId: Int, schedule: Schedule?) -> Int32 {
        let id = getNextId(for: "tracker")
        trackers.append(Tracker(id: id, title: title, emoji: emoji, color: color, categoryId: categoryId, schedule: schedule))
        return id
    }
    
    func updateCategory(id: Int, name: String) {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(id)")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let fetchedResults = try? context.fetch(fetchRequest)
            if let category = fetchedResults?.first {
                category.name = name
            }
            try context.save()
        } catch {
            print("Error")
        }
    }
    
    private func getNextId(for entity: String) -> Int32 {
        var maxId: Int32?
        switch entity {
        //case "category": maxId = categories.max(by: { a, b in a.id < b.id })?.id
        case "tracker": maxId = trackers.max(by: { a, b in a.id < b.id })?.id
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
    
    func getCategory(_ id: Int32) -> Category? {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(id)")
        fetchRequest.returnsObjectsAsFaults = false
        
        let fetchedResults = try? context.fetch(fetchRequest)
        if let category = fetchedResults?.first {
            return Category(id: category.id, name: category.name ?? const.noName)
        } else {
            return nil
        }
    }
    /*
    func getCategoryNameById(id: Int) -> String? {
        if let index = categories.firstIndex(where: { $0.id == id }) {
            return categories[index].name
        } else {
            return nil
        }
    }
    */
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let inserted = insertedIndexes,
              let deleted = deletedIndexes,
              let updated = updatedIndexes
        else { return }

        //delegate?.didUpdate(TrackersStoreUpdate(insertedIndexes: inserted, deletedIndexes: deleted, updatedIndexes: updated))
        
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        case .update:
            if let indexPath = indexPath {
                updatedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
/*
extension DataManagement {
    var numberOfSections: Int{
        fetchResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        fetchResultsController.object(at: indexPath)
    }
}
*/
