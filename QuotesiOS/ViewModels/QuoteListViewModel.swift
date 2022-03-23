//
//  QuoteListViewModel.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-22.
//

import UIKit

class QuoteListViewModel {
    private static var quoteList: [QuoteItem]?
    
    public init() {
        do {
            if QuoteListViewModel.quoteList == nil {
                let dbService: DatabaseService = DatabaseService()
                QuoteListViewModel.quoteList = try dbService.fetchAll(itemType: QuoteItem.self) as? [QuoteItem]
            }
        } catch let error as NSError {
            fatalError("Unable to load the app's database. Please, try again.\nError: \(error.localizedDescription)")
        }
    }
    
    /// Retrieves all the quotes saved in the Core Data.
    /// - Note:
    ///     If there is already elements in the **local** `quoteList` it doesn't overwrite the current **local** quotes. In this case, it just returns the current list.
    @discardableResult
    public func getQuoteList() -> [QuoteItem]? {
        var quoteList = QuoteListViewModel.quoteList!
        quoteList.sort(by: { $0.dateAdded! > $1.dateAdded! })
        
        return quoteList
    }
    
    public func getContentFromIndex(_ index: Int) -> (String?, String?) {
        let quote = QuoteListViewModel.quoteList![index]
        
        return (quote.content, quote.author)
    }
    
    public func isQuoteSaved(quoteId id: String) -> Bool {
        let search = QuoteListViewModel.quoteList!.filter { $0.id == id }
        return search.count != 0
    }
    
    public func quoteListLength() -> Int {
        return QuoteListViewModel.quoteList!.count
    }
    
    public func addToQuoteList(quote: QuoteItem) throws -> Bool {
        if let quoteID = quote.id, !isQuoteSaved(quoteId: quoteID) {
            let dbService = DatabaseService()
            try dbService.createOne(item: quote)
            
            QuoteListViewModel.quoteList!.append(quote)
            return true
        }
            
        return false
    }
    
    @discardableResult
    public func removeQuoteFromList(quoteId: String) -> Bool {
        let quotes = QuoteListViewModel.quoteList!.filter { $0.id == quoteId }
        
        if let quote = quotes.first {
            let dbService = DatabaseService()
            try! dbService.deleteOne(item: quote)
            
            let index = quotes.firstIndex(of: quote)
            QuoteListViewModel.quoteList!.remove(at: index!)
            
            return true
        }
        
        return false
    }
    
    @discardableResult
    public func removeQuoteFromIndex(_ index: Int) -> Bool {
        let quote = QuoteListViewModel.quoteList![index]
        
        return removeQuoteFromList(quoteId: quote.id!)
    }
}
