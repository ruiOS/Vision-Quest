//
//  Persistant Storage.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import CoreData

///class used to PersistentStorage
final class PersistentStorage {

    //MARK: - Singleton
    ///object of PersistentStorage
    static let shared: PersistentStorage = PersistentStorage()

    private init(){}

    // MARK: - Core Data stack
    ///Container that encapsulates the Core Data stack in the app
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Vision_Quest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    ///The main queue’s managed object context.
    lazy var context = persistentContainer.viewContext

    // MARK: - Core Data Saving support
    ///method used to save changes in context
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /// method return fetched data of entity
    /// - Returns: fetched data entity type
    func fetchManagedObject<T: NSManagedObject>(managedObject: T.Type) -> [T]{
        do{
            if let result: [T] = try context.fetch(managedObject.fetchRequest()) as? [T] {
                return result
            }
        }catch{
            debugPrint(error)
        }
        return [T]()
    }
    
    /// method returns fetched data based on conditions
    /// - Parameter predicate: predicate to fetch data
    /// - Parameter sortDescriptors: sortDescriptors to sort data
    /// - Returns: fetched data based on conditions
    func fetchObjects<T: NSFetchRequestResult & NSManagedObjectEntityProtocol>(
        usingPredicate predicate: NSPredicate? = nil,
        withSortDescriptors sortDescriptors: [NSSortDescriptor]? = nil) -> [T]?
    {

        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        if let sortDescriptors = sortDescriptors{
            fetchRequest.sortDescriptors = sortDescriptors
        }

        do {
            return try PersistentStorage.shared.context.fetch(fetchRequest)
        }
        catch{
            debugPrint(error)
        }
        return nil
    }

    func deleteAllData(for entities: [String]) {
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(deleteRequest)
            } catch {
            }
        }
        saveContext()
    }
}
