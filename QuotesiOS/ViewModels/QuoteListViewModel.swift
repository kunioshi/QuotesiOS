//
//  QuoteListViewModel.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-22.
//

import UIKit
import RxSwift
import RxCocoa

class QuoteListViewModel {
    public let quoteList = BehaviorRelay(value: [QuoteItem]())
    
    public init() {
        do {
            try refreshList()
        } catch let error as NSError {
            fatalError("Unable to load the app's database. Please, try again.\nError: \(error.localizedDescription)")
        }
    }
    
    /// Retrieves all the quotes saved in the Core Data.
    /// - Note:
    ///     If there is already elements in the **local** `quoteList` it doesn't overwrite the current **local** quotes. In this case, it just returns the current list.
    @discardableResult
    public func getQuoteList() -> [QuoteItem]? {
        let quoteItems = quoteList.value
        
        return quoteItems
    }
    
    public func getContentFromIndex(_ index: Int) -> (String?, String?) {
        let quote = quoteList.value[index]
        
        return (quote.content, quote.author)
    }
    
    public func isQuoteSaved(quoteId id: String) -> Bool {
        let search = quoteList.value.filter { $0.id == id }
        return search.count != 0
    }
    
    public func quoteListLength() -> Int {
        return quoteList.value.count
    }
    
    public func refreshList() throws {
        let db: DatabaseService = DatabaseService()
        let quoteItems = try db.fetchAll(itemType: QuoteItem.self) as! [QuoteItem]
        quoteList.accept(quoteItems)
    }
    
    @discardableResult
    public func removeQuoteFromList(quoteId: String) -> Bool {
        let quotes = quoteList.value.filter { $0.id == quoteId }
        
        if let quote = quotes.first {
            let db = DatabaseService()
            try! db.deleteOne(item: quote)
        }
        
        return false
    }
    
    @discardableResult
    public func removeQuoteFromIndex(_ index: Int) -> Bool {
        let quote = quoteList.value[index]
        
        return removeQuoteFromList(quoteId: quote.id!)
    }
}
