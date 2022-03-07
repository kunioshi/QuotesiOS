//
//  QuoteController.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-07.
//

import UIKit
import CoreData

class QuoteController {
    static var quoteList = [QuoteItem]()
    static let context: NSManagedObjectContext =
        (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    
    /// Retrieves all the quotes saved in the Core Data.
    /// - Note:
    ///     If there is already elements in the **local** `quoteList` it doesn't overwrite the current **local** quotes. In this case, it just returns the current list.
    static func getQuotes() -> [QuoteItem] {
        if QuoteController.quoteList.count == 0 {
            do {
                QuoteController.quoteList = try QuoteController.context.fetch(QuoteItem.fetchRequest())
                
                return QuoteController.quoteList
            } catch let error as NSError {
                print("ERROR! Couldn't load Quotes from Core Data: \(error).")
                return []
            }
        }
        
        return QuoteController.quoteList
    }
    
    static func isQuoteSaved(id: String) -> Bool {
        let search = QuoteController.quoteList.filter { $0.id == id }
        
        return search.count != 0
    }
    
    static func saveQuote(_ quote: QuoteItem) -> Bool {
        let ctx = QuoteController.context
        ctx.insert(quote)
        
        let isSaved = QuoteController.saveContext()
        if isSaved {
            quoteList.append(quote)
        }
        
        return isSaved
    }
    
    static func createQuote(id: String, content: String, author: String) -> QuoteItem {
        let newQuote = QuoteItem(context: QuoteController.context)
        
        newQuote.id = id
        newQuote.content = content
        newQuote.author = author
        newQuote.dateAdded = Date()
        
        return newQuote
    }
    
    static func deleteQuote(id: String) -> Bool {
        let quotes = QuoteController.quoteList.filter { $0.id == id }
        
        if let quote = quotes.first {
            QuoteController.context.delete(quote)
            
            return saveContext()
        }
        
        return false
    }
    
    static func saveContext() -> Bool {
        do {
            try QuoteController.context.save()
            
            return true
        } catch let error as NSError {
            print("ERROR! Couldn't save the context: \(error)")
            
            return false
        }
    }
    
    /// Erase all Quotes frim the Data Core!
    /// - Warning:
    ///     This operation is irreversible!
    static func deleteAllQuotes() {
        for quote in QuoteController.quoteList {
            QuoteController.context.delete(quote)
        }
        
        if !saveContext() {
            print("Error deleting ALL quotes!")
        }
    }
}
