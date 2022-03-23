//
//  CoreDataService.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-22.
//

import UIKit
import CoreData

enum DatabaseError: Error {
    case databaseFetchError(String)
    case databaseSaveContextError
    case databaseSaveOneError
}

class DatabaseService {
    private static let context: NSManagedObjectContext =
        (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    
    public static func getContext() -> NSManagedObjectContext {
        return DatabaseService.context
    }
    
    @discardableResult
    public func createOne(item: NSManagedObject) throws -> NSManagedObject {
        DatabaseService.context.insert(item)
        
        do {
            try saveContext()
        } catch {
            throw DatabaseError.databaseSaveOneError
        }
        
        return item
    }
    
    public func fetchAll(itemType: NSManagedObject.Type) throws -> [NSManagedObject] {
        do {
            return try DatabaseService.context.fetch(itemType.fetchRequest()) as! [NSManagedObject]
        } catch let error as NSError {
            throw DatabaseError.databaseFetchError(error.description)
        }
    }
    
    public func fetchOne(withObjectID objectID: NSManagedObjectID) throws -> NSManagedObject {
        do {
            return try DatabaseService.context.existingObject(with: objectID)
        } catch let error as NSError {
            throw DatabaseError.databaseFetchError(error.description)
        }
    }
    
    @discardableResult
    public func updateOne(item: NSManagedObject) -> NSManagedObject {
        return item
    }
    
    public func deleteOne(item: NSManagedObject) throws {
        DatabaseService.context.delete(item)
        
        try saveContext()
    }
    
    private func saveContext() throws {
        do {
            try DatabaseService.context.save()
        } catch {
            throw DatabaseError.databaseSaveContextError
        }
    }
}
