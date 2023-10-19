//
//  StorageManager.swift
//  Lesson 3.6 CoreData
//
//  Created by Артём Потёмкин on 18.10.2023.
//

import Foundation
import CoreData

final class StorageManager {
    
    static let shared = StorageManager()
    
    private init () {}
    
    // MARK: - Core Data stack
    
    var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Lesson_3_6_CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    func create(_ taskName: String, completion: (Task) -> Void) {
        let task = Task(context: persistentContainer.viewContext)
        task.title = taskName
        completion(task)
        saveContext()
    }
    
    func delete(_ task: Task) {
        persistentContainer.viewContext.delete(task)
        saveContext()
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

