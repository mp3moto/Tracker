import UIKit
import CoreData

struct TrackersStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}
/*
protocol CategoryRecordProtocol {
    var id: Int32 { get }
    var name: String { get }
}

@objc(CategoryRecord)
class CategoryRecord: NSManagedObject, CategoryRecordProtocol {
    @NSManaged var id: Int32
    @NSManaged var name: String
}
*/
protocol DataManagementDelegate: AnyObject {
    func didUpdate(_ update: TrackersStoreUpdate)
}

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
        print(fetchResultsController.fetchedObjects?.count)
        return fetchResultsController
    }()
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    weak var delegate: DataManagementDelegate?
    
    var categories: [Category] {
        get {
            let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
            var categories: [Category] = []
            do {
                let fetchedData = try context.fetch(request)
                fetchedData.forEach {
                    categories.append(Category(id: $0.id, name: $0.name ?? "Без названия"))
                }
            } catch let error {
                print(error.localizedDescription)
            }
            return categories
        }
        /*
        set {
            
            if let data = try? PropertyListEncoder().encode(newValue) {
                userDefaults.set(data, forKey: Keys.categories.rawValue)
            }
        }
         */
    }
    
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
        case "category": return categories.count
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
        //delegate?.
        //categories.append(Category(id: Int32(id), name: name))
        return id
    }
    
    func deleteCategory() {
        
    }
    
    func addTracker(title: String, emoji: String, color: String, categoryId: Int, schedule: Schedule?) -> Int32 {
        let id = getNextId(for: "tracker")
        trackers.append(Tracker(id: id, title: title, emoji: emoji, color: color, categoryId: categoryId, schedule: schedule))
        return id
    }
    
    func updateCategory(id: Int, name: String) {
        /*
        if let index = categories.firstIndex(where: { $0.id == id }) {
            categories[index] = Category(id: Int32(id), name: name)
        }
        */
    }
    
    private func getNextId(for entity: String) -> Int32 {
        var maxId: Int32?
        switch entity {
        case "category": maxId = categories.max(by: { a, b in a.id < b.id })?.id
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
    
    func getCategoryNameById(id: Int) -> String? {
        if let index = categories.firstIndex(where: { $0.id == id }) {
            return categories[index].name
        } else {
            return nil
        }
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerWillChangeContent called")
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        print("insertedIndexes = \(insertedIndexes)")
        print("deletedIndexes = \(deletedIndexes)")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerDidChangeContent called")
        guard let inserted = insertedIndexes,
              let deleted = deletedIndexes
        else { return }
        print("inserted = \(inserted)")
        print("deleted = \(deleted)")
        delegate?.didUpdate(TrackersStoreUpdate(insertedIndexes: inserted, deletedIndexes: deleted))
        
        self.insertedIndexes = nil
        self.deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            print(".insert, controller didChange called with indexPath = \(indexPath)")
            if let indexPath = indexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}

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
