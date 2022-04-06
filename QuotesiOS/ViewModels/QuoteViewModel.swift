//
//  QuoteViewModel.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-07.
//

import UIKit
import RxSwift
import RxCocoa

class QuoteViewModel {
    public var currentQuote: BehaviorRelay<APIQuoteModel> = BehaviorRelay(value: APIQuoteModel())
    private var quoteDidSet: () -> Void
    
    init(newQuoteCallback: @escaping () -> Void) {
        quoteDidSet = newQuoteCallback
    }
    
    @discardableResult
    public func saveCurrentQuote() -> Bool {
        let quote = currentQuote.value
        if quote._id != nil {
            let newQuote = APIService().createQuoteItem(fromQuoteAPI: quote)
            
            do {
                let db = DatabaseService()
                try db.createOne(item: newQuote)
                
                return true
            } catch let error {
                print(error)
            }
        }
        
        return false
    }
    
    public func getNewQuote() {
        let api = APIService()
        api.fetchAPIQuote(completion: setNewQuote)
    }
    
    /// Callback from API fetch (`APIService().fetchAPIQuote`)
    public func setNewQuote(_ quote: QuoteModel?) {
        if var apiQuote = quote as? APIQuoteModel {
            // Customize the content for the app
            apiQuote.content = addQuoteMark(quote: apiQuote.content)
            
            currentQuote.accept(apiQuote)
        }
    }
    
    /// Adds custom quotation marks to the given String, if not nil.
    private func addQuoteMark(quote: String?) -> String? {
        if let text = quote {
            return "“"+text+"”"
        }
        
        return nil
    }
    
    public func getCurrentContent() -> (String, String) {
        let quote = currentQuote.value
        if let content = quote.content, let author = quote.author {
            return (content, author)
        }
        
        return ("No Quote Found", "System")
    }
    
    @discardableResult
    public func removeCurrentQuote() -> Bool {
        let quote = currentQuote.value
        if let id = quote._id {
            let quoteListVM = QuoteListViewModel()
            return quoteListVM.removeQuoteFromList(quoteId: id)
        }
        
        return false
    }
    
    public func isCurrentQuoteSaved() -> Bool {
        let quote = currentQuote.value
        if let id = quote._id {
            let db = DatabaseService()
            
            do {
                let count = try db.countEntity(ifType: QuoteItem.self, withID: id)
                
                return count != 0
            } catch {
                print(error)
            }
        }
        
        return false
    }
}
