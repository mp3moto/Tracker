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
    let context: NSManagedObjectContext
    var dateFromDatePicker: Date?
    weak var categoriesDelegate: DataStoreDelegate?
    weak var trackersDelegate: DataStoreDelegate?
    weak var trackerRecordDelegate: DataStoreDelegate?
    
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
    
   
    private lazy var trackerRecordsFRC = NSFetchedResultsController<TrackerRecordCoreData>()/* = {
        
    }()*/
    
    var categories: [Category] {
        get {
            var categories: [Category] = []
                let fetchedData = categoriesFRC.fetchedObjects
                fetchedData?.forEach {
                    categories.append(Category(name: $0.name ?? Const.noName))
                }
            return categories
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
    }
    
    override convenience init() {
        let helper = DataStoreHelper()
        self.init(context: helper.persistentContainer.viewContext)
    }
    
    func saveRecord<E: NSManagedObject>(object: E) throws {
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
    
    func deleteRecord<E: NSManagedObject>(object: E) throws {
        context.delete(object)
        try context.save()
    }
    
    func getRecords<E: NSManagedObject>(className: CoreDataClasses, sql: String? = nil, additionalParam: AnyObject? = nil) -> [E] {
        switch className {
        case .TrackerCoreData:
            guard let sql = sql else { return [] }
            trackersFRC.fetchRequest.predicate = NSPredicate(format: "\(sql)")
            try? trackersFRC.performFetch()
            guard let objects = trackersFRC.fetchedObjects as? [E] else { return [] }
            return objects
        case .TrackerCategoryCoreData:
            try? categoriesFRC.performFetch()
            guard let objects = categoriesFRC.fetchedObjects as? [E] else { return [] }
            return objects
        case .TrackerRecordCoreData:
            guard let additionalParam = additionalParam as? CVarArg,
                  let sql = sql
            else { return [] }
            let request = NSFetchRequest<E>(entityName: className.rawValue)
            request.predicate = NSPredicate(format: sql, additionalParam)
            //request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let objects = try? context.fetch(request)
            return objects ?? []
        }
    }
    
    func makeSortDescriptors(_ input: [SortDescriptor]) -> [NSSortDescriptor] {
        var result: [NSSortDescriptor] = []
        input.forEach { item in
            result.append(NSSortDescriptor(key: "\(item.name)", ascending: item.ascending))
        }
        return result
    }
    
    func query<E: NSManagedObject>(
        className: CoreDataClasses,
        sql: String? = nil,
        paramsForSql: [Any]? = nil,
        sortDescriptors: [SortDescriptor]? = nil,
        limit: Int? = nil
    ) -> [E] {
        let fetchRequest = NSFetchRequest<E>(entityName: className.rawValue)
        if let sql = sql {
            fetchRequest.predicate = NSPredicate(format: sql, argumentArray: paramsForSql)
        }
        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = makeSortDescriptors(sortDescriptors)
        }
        fetchRequest.fetchLimit = limit ?? 0
        let objects = try? context.fetch(fetchRequest)
        return objects ?? []
    }
    
    func getRecordsCount(className: CoreDataClasses) -> Int {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: className.rawValue)
        fetchRequest.resultType = .countResultType
        return (try? context.fetch(fetchRequest).first)?.intValue ?? 0
    }
    
    
    
    func numberOfRowsInSectionForCategories(_ section: Int) -> Int {
        categoriesFRC.sections?[section].numberOfObjects ?? 0
    }
    
    func categoryObject(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        categoriesFRC.object(at: indexPath)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        trackersDelegate?.didUpdate()
    }
}
