import UIKit
import CoreData

protocol DataStoreDelegate: AnyObject {
    func didUpdate()
}

// This helps to match single import CoreData requirement in sprint 15
final class DataStoreHelper {
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError(error.localizedDescription)
            }
        })
        return container
    }()
}

final class DataStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    var dateFromDatePicker: Date?
    weak var categoriesDelegate: DataStoreDelegate?
    weak var trackersDelegate: DataStoreDelegate?
    weak var trackerRecordDelegate: DataStoreDelegate?
    var searchQuery: String = ""
    private var safeMode: Bool = false {
        didSet {
            if safeMode == true {
                trackersFRC.fetchRequest.predicate = NSPredicate(format: "(schedule = NULL)")
            } else {
                trackersFRC.fetchRequest.predicate = NSPredicate(format: "(schedule & \(getWeekDay()) != 0) OR (schedule = NULL)")
            }
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    override convenience init() {
        let helper = DataStoreHelper()
        self.init(context: helper.persistentContainer.viewContext)
    }
    
    func prepareSQLQueryString() -> String {
        if safeMode {
            return "(schedule = NULL)"
        }
        let defaultResult = "(schedule & \(getWeekDay()) != 0) OR (schedule = NULL)"
        if searchQuery.count > 0 {
            return "(\(defaultResult)) AND title CONTAINS[c] '\(searchQuery)'"
        } else {
            searchQuery = ""
            return defaultResult
        }
    }
    
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
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.name),
            cacheName: nil
        )
        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()
        
        return fetchResultsController
    }()
    
    var categories: [Category] {
        get {
            var categories: [Category] = []
                let fetchedData = categoriesFRC.fetchedObjects
                fetchedData?.forEach {
                    categories.append(Category(id: $0.id, name: $0.name ?? Const.noName))
                }
            return categories
        }
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
                trackersFRC.fetchRequest.predicate = NSPredicate(format: prepareSQLQueryString())
                try trackersFRC.performFetch()
            } catch let error {
                print(error.localizedDescription)
            }
            
            let doneRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
            var trackers: [Tracker] = []
            do {
                let fetchedDoneData = try context.fetch(doneRequest)
                trackersFRC.fetchedObjects?.forEach {
                    let category = $0.category?.name
                    let trackerId = $0.id
                    var schedule: Schedule?
                    if let _ = $0.schedule {
                        schedule = unpackSсhedule($0.schedule as? Int32 ?? 0)
                    }
                    if let category = category {
                        trackers.append(
                            Tracker(
                                id: trackerId,
                                title: $0.title ?? Const.noName,
                                emoji: $0.emoji ?? Const.emptyString,
                                color: $0.color ?? Const.defaultColor,
                                category: category,
                                schedule: schedule,
                                doneCount: fetchedDoneData.filter { $0.tracker?.id == trackerId }.count,
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
        if let tracker = getTrackerEntity(trackerId) {
            if tracker.schedule == nil {
                tracker.schedule = 0
            }
            try context.save()
        }

        let newTrackerRecord = TrackerRecordCoreData(context: context)
        newTrackerRecord.doneAt = doneAt
        newTrackerRecord.tracker = getTrackerEntity(trackerId)
        try context.save()

        if let tracker = getTrackerEntity(trackerId) {
            if tracker.schedule == 0 {
                tracker.schedule = nil
                safeMode = true
            }
        }
        
        try context.save()
        safeMode = false
    }
    
    func getTrackerRecordEntity(doneAt: Date, trackerId: Int32) -> TrackerRecordCoreData? {
        guard let tracker = getTrackerEntity(trackerId) else { return nil }
        if tracker.schedule == nil {
            safeMode = true
        }
        var trackerRecord: TrackerRecordCoreData?
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.returnsObjectsAsFaults = false
        
        let fetchedResults = try? context.fetch(fetchRequest)
        trackerRecord = fetchedResults?.filter { $0.tracker == tracker && $0.doneAt == doneAt }.first
        
        return trackerRecord
    }
    
    func isTrackerDone(atDate: Date, trackerId: Int32) -> Bool {
        trackerRecords.filter { $0.trackerId == trackerId && $0.doneAt == atDate }.count > 0 ? true : false
    }
    
    func deleteTrackerDone(atDate: Date, trackerId: Int32) throws {
        guard let trackerRecord = getTrackerRecordEntity(doneAt: atDate, trackerId: trackerId) else { return }
        do {
            context.delete(trackerRecord)
            try context.save()
            if safeMode == true {
                safeMode = false
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func addTracker(title: String, emoji: String, color: String, category: TrackerCategoryCoreData, schedule: Schedule?) throws -> Int32 {
        let id = getNextId(for: "tracker")
        
        let newTracker = TrackerCoreData(context: context)
        newTracker.id = id
        newTracker.title = title
        newTracker.emoji = emoji
        newTracker.color = color
        if let schedule = schedule {
            newTracker.schedule = (schedule.packed()) as NSNumber
        } else {
            newTracker.schedule = nil
            safeMode = true
        }
        newTracker.category = category
        
        try context.save()
        safeMode = false
        
        try trackersFRC.performFetch()

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
            return Category(id: category.id, name: category.name ?? Const.noName)
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
    
    func categoryObject(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        categoriesFRC.object(at: indexPath)
    }
    
    private func getNextId(for entity: String) -> Int32 {
        var maxId: Int32?
        switch entity {
        case "category":
            let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "id", ascending: false) ]
            let fetchedResults = try? context.fetch(fetchRequest)
            if let category = fetchedResults?.first {
                maxId = category.id
            } else {
                maxId = 0
            }
        case "tracker":
            let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "id", ascending: false) ]
            let fetchedResults = try? context.fetch(fetchRequest)
            if let tracker = fetchedResults?.first {
                maxId = tracker.id
            } else {
                maxId = 0
            }
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
