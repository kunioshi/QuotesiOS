//
//  QuoteController.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-07.
//

import UIKit
import CoreData

class QuoteModelView {
    static var quoteList = [QuoteItem]()
    static let context: NSManagedObjectContext =
        (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    
    /// Retrieves all the quotes saved in the Core Data.
    /// - Note:
    ///     If there is already elements in the **local** `quoteList` it doesn't overwrite the current **local** quotes. In this case, it just returns the current list.
    @discardableResult
    static func getQuotes() -> [QuoteItem] {
        if QuoteModelView.quoteList.count == 0 {
            do {
                QuoteModelView.quoteList = try QuoteModelView.context.fetch(QuoteItem.fetchRequest())
                
                return QuoteModelView.quoteList
            } catch let error as NSError {
                print("ERROR! Couldn't load Quotes from Core Data: \(error).")
                return []
            }
        }
        
        QuoteModelView.quoteList.sort(by: { $0.dateAdded! > $1.dateAdded! })
        
        return QuoteModelView.quoteList
    }
    
    static func isQuoteSaved(id: String) -> Bool {
        let search = QuoteModelView.quoteList.filter { $0.id == id }
        
        return search.count != 0
    }
    
    static func saveQuote(_ quote: QuoteItem) -> Bool {
        let ctx = QuoteModelView.context
        ctx.insert(quote)
        
        let isSaved = QuoteModelView.saveContext()
        if isSaved {
            quoteList.append(quote)
        }
        
        return isSaved
    }
    
    static func createQuote(id: String, content: String, author: String) -> QuoteItem {
        let newQuote = QuoteItem(context: QuoteModelView.context)
        
        newQuote.id = id
        newQuote.content = content
        newQuote.author = author
        newQuote.dateAdded = Date()
        
        return newQuote
    }
    
    static func deleteQuote(id: String) -> Bool {
        let quotes = QuoteModelView.quoteList.filter { $0.id == id }
        
        if let quote = quotes.first {
            QuoteModelView.context.delete(quote)
            
            let index = QuoteModelView.quoteList.firstIndex(of: quote)
            QuoteModelView.quoteList.remove(at: index!)
            
            return saveContext()
        }
        
        return false
    }
    
    static func saveContext() -> Bool {
        do {
            try QuoteModelView.context.save()
            
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
        for quote in QuoteModelView.quoteList {
            QuoteModelView.context.delete(quote)
        }
        
        if !saveContext() {
            print("Error deleting ALL quotes!")
        }
    }
}
