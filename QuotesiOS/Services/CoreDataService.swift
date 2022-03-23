//
//  CoreDataService.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-22.
//

import UIKit
import CoreData

enum CoreDataError: Error {
    case coreDataFetchError(String)
    case coreDataSaveContextError
    case coreDataSaveOneError
}

class DatabaseService {
    private static let context: NSManagedObjectContext =
        (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    
    func teste(testItem: NSObject) -> Bool {
        return true
    }
    
    public func createOne(item: NSManagedObject) throws -> NSManagedObject {
        DatabaseService.context.insert(item)
        
        do {
            try saveContext()
        } catch {
            throw CoreDataError.coreDataSaveOneError
        }
        
        return item
    }
    
    public func fetchAll(itemType: NSManagedObject.Type) throws -> [NSManagedObject] {
        do {
            return try DatabaseService.context.fetch(itemType.fetchRequest()) as! [NSManagedObject]
        } catch let error as NSError {
            throw CoreDataError.coreDataFetchError(error.description)
        }
    }
    
    public func fetchOne(withObjectID objectID: NSManagedObjectID) throws -> NSManagedObject {
        do {
            return try DatabaseService.context.existingObject(with: objectID)
        } catch let error as NSError {
            throw CoreDataError.coreDataFetchError(error.description)
        }
    }
    
    public func updateOne(item: NSManagedObject) -> NSManagedObject {
        return item
    }
    
    private func saveContext() throws {
        do {
            try DatabaseService.context.save()
        } catch {
            throw CoreDataError.coreDataSaveContextError
        }
    }
}
