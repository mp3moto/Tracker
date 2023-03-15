import UIKit
import CoreData

protocol DataStoreDelegate: AnyObject {
    func didUpdate()
}

final class DataStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    var dateFromDatePicker: Date?
    weak var categoriesDelegate: DataStoreDelegate?
    weak var trackersDelegate: DataStoreDelegate?
    weak var trackerRecordDelegate: DataStoreDelegate?
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
            }
        })
        return container
    }()
    
    private lazy var categoriesFRC: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()
        
        return fetchResultsController
    }()
    
    private lazy var trackersFRC: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let fetchResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category),
            cacheName: nil
        )
        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()
        
        return fetchResultsController
    }()
    
    override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    var categories: [Category] {
        get {
            /*do {
                try categoriesFRC.performFetch()
            } catch let error {
                print(error.localizedDescription)
            }*/
            //let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
            var categories: [Category] = []
            //do {
                let fetchedData = categoriesFRC.fetchedObjects
                //let fetchedData = try context.fetch(request)
                fetchedData?.forEach {
                    categories.append(Category(id: $0.id, name: $0.name ?? const.noName))
                }
            //} catch let error {
            //    print(error.localizedDescription)
            //}
            return categories
        }
    }
    
    func unpackShedule(_ packed: Int32) -> Schedule {
        Schedule(
            mon: packed & 64 == 64 ? true : false,
            tue: packed & 32 == 32 ? true : false,
            wed: packed & 16 == 16 ? true : false,
            thu: packed & 8 == 8 ? true : false,
            fri: packed & 4 == 4 ? true : false,
            sat: packed & 2 == 2 ? true : false,
            sun: packed & 1 == 1 ? true : false
        )
    }
    
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
    
    var trackers: [Tracker] {
        get {
            do {
                let weekday = getWeekDay()
                trackersFRC.fetchRequest.predicate = NSPredicate(format: "(schedule & \(weekday) != 0) OR (schedule = NULL)")
                //trackersFRC.fetchRequest.predicate = NSPredicate(format: "(schedule = NULL)")
                try trackersFRC.performFetch()
            } catch {
                
            }
            
            let doneRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
            var trackers: [Tracker] = []
            do {
                //let fetchedData = try context.fetch(request)
                let fetchedDoneData = try context.fetch(doneRequest)
                trackersFRC.fetchedObjects?.forEach {
                //fetchedData.forEach {
                    let categoryId = $0.category?.id
                    let trackerId = $0.id
                    var schedule: Schedule?
                    if let _ = $0.schedule {
                        schedule = unpackShedule($0.schedule as? Int32 ?? 0)
                    }
                    if let categoryId = categoryId {
                        trackers.append(
                            Tracker(
                                id: trackerId,
                                title: $0.title ?? const.noName,
                                emoji: $0.emoji ?? const.emptyString,
                                color: $0.color ?? const.defaultColor,
                                categoryId: categoryId,
                                schedule: schedule,
                                done: fetchedDoneData.filter { $0.doneAt == dateFromDatePicker && $0.tracker?.id == trackerId }.count > 0
                            )
                        )
                    }
                }
                return trackers
            } catch let error {
                print(error.localizedDescription)
                return trackers
            }
        }
    }
    
    var trackerRecords: [TrackerRecord] {
        get {
            let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
            var trackerRecords: [TrackerRecord] = []
            do {
                let fetchedData = try context.fetch(request)
                fetchedData.forEach {
                    guard let id = $0.tracker?.id,
                          let date = $0.doneAt else { return }
                    trackerRecords.append(TrackerRecord(trackerId: id, doneAt: date))
                }
                return trackerRecords
            } catch let error {
                print(error.localizedDescription)
                return trackerRecords
            }
        }
    }
    
    func addTrackerRecord(doneAt: Date, trackerId: Int32) throws {
        let newTrackerRecord = TrackerRecordCoreData(context: context)
        newTrackerRecord.doneAt = doneAt
        newTrackerRecord.tracker = getTrackerEntity(trackerId)
        
        try context.save()
    }
    
    func isTrackerDone(atDate: Date, trackerId: Int32) -> Bool {
        trackerRecords.filter { $0.trackerId == trackerId && $0.doneAt == atDate }.count > 0 ? true : false
    }
    
    func deleteTrackerDone(atDate: Date, trackerId: Int) throws {
        guard let trackerRecord = trackerRecords.filter({ $0.trackerId == trackerId && $0.doneAt == atDate }) as? [NSManagedObject],
              let record = trackerRecord.first
        else { return }
        do {
            context.delete(record)
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func addTracker(title: String, emoji: String, color: String, categoryId: Int32, schedule: Schedule?) throws -> Int32 {
        trackersFRC.fetchRequest.predicate = NSPredicate()
        let id = getNextId(for: "tracker")
        
        let newTracker = TrackerCoreData(context: context)
        newTracker.id = id
        newTracker.title = title
        newTracker.emoji = emoji
        newTracker.color = color
        if let schedule = schedule {
            newTracker.schedule = (schedule.packed()) as NSNumber
        }
        newTracker.category = try getCategoryEntity(categoryId)
        
        try context.save()
        
        return id
    }
    
    func getTrackerEntity(_ id: Int32) -> TrackerCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(id)")
        fetchRequest.returnsObjectsAsFaults = false
        
        let fetchedResults = try? context.fetch(fetchRequest)
        if let tracker = fetchedResults?.first {
            return tracker
        } else {
            return nil
        }
    }
    
    var numberOfSectionsForCategories: Int {
        categoriesFRC.sections?.count ?? 0
    }
    
    func getCategory(_ id: Int32) throws -> Category? {
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
    
    func getCategoryEntity(_ id: Int32) throws -> TrackerCategoryCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(id)")
        fetchRequest.returnsObjectsAsFaults = false
        
        let fetchedResults = try? context.fetch(fetchRequest)
        if let category = fetchedResults?.first {
            return category
        } else {
            return nil
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
    
    func updateCategory(id: Int, name: String) throws {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(id)")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let fetchedResults = try? context.fetch(fetchRequest)
            if let category = fetchedResults?.first {
                category.name = name
                try context.save()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func deleteCategory(_ id: Int32) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(id)")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            guard let fetchedResults = try context.fetch(fetchRequest) as? [NSManagedObject] else { return }
            for record in fetchedResults {
                context.delete(record)
            }
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func numberOfRowsInSectionForCategories(_ section: Int) -> Int {
        categoriesFRC.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSectionsForTrackers() -> Int {
        trackersFRC.sections?.count ?? 0
    }
    
    func numberOfRowsInSectionForTrackers(_ section: Int) -> Int {
        trackersFRC.sections?[section].numberOfObjects ?? 0
    }
    
    func categoryObject(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        categoriesFRC.object(at: indexPath)
    }
    
    func trackerObject(at indexPath: IndexPath) -> TrackerCoreData? {
        trackersFRC.object(at: indexPath)
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        switch controller {
        case categoriesFRC:
            categoriesDelegate?.didUpdate()
        case trackersFRC:
            trackersDelegate?.didUpdate()
        default:
            break
        }
    }
}
