//
//  QuoteViewModel.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-07.
//

import UIKit

class QuoteViewModel {
    private var currentQuote: APIQuoteModel? { didSet { quoteDidSet() } }
    private var quoteDidSet: () -> Void
    
    init(newQuoteCallback: @escaping () -> Void) {
        quoteDidSet = newQuoteCallback
    }
    
    public func saveQuote(_ quote: QuoteItem) -> Bool {
        do {
            let quoteListVM = QuoteListViewModel()
            if try quoteListVM.addToQuoteList(quote: quote) {
                return true
            }
        } catch let error {
            print(error)
        }
        
        return false
    }
    
    @discardableResult
    public func saveCurrentQuote() -> Bool {
        if let curQuote = currentQuote {
            let newQuote = APIService().createQuoteItem(fromQuoteAPI: curQuote)
            
            return saveQuote(newQuote)
        }
        
        return false
    }
    
    public func getNewQuote() {
        let api = APIService()
        api.fetchAPIQuote(completion: setNewQuote)
    }
    
    public func setNewQuote(_ quote: QuoteModel?) {
        if let apiQuote = quote as? APIQuoteModel {
            currentQuote = apiQuote
        }
    }
    
    public func getCurrentContent() -> (String, String) {
        if let quote = currentQuote, let content = quote.content, let author = quote.author {
            return (content, author)
        }
        
        return ("No Quote Found", "System")
    }
    
    public func removeQuote(id: String) -> Bool {
        let quoteListVM = QuoteListViewModel()
        return quoteListVM.removeQuoteFromList(quoteId: id)
    }
    
    public func isCurrentQuoteSaved() -> Bool {
        let quoteListVM = QuoteListViewModel()
        return (currentQuote != nil && quoteListVM.isQuoteSaved(quoteId: currentQuote!._id!))
    }
}
