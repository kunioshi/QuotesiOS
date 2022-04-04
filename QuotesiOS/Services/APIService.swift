//
//  QuoteFetcher.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-21.
//

import Foundation
import Alamofire

enum APIError: Error {
    case responseInvalidValue
}

struct APIQuoteModel: QuoteModel {
    var _id: String?
    var content: String?
    var author: String?
}

class APIService {
    private let apiURL = "https://api.quotable.io/random"
    
    public func fetchAPIQuote(completion: @escaping (QuoteModel?) -> Void) {
        AF.request(self.apiURL).responseDecodable(of: APIQuoteModel.self) { (response) in
            guard let apiQuote = response.value else {
                completion(nil)
                return
            }
            
            completion(apiQuote)
            return
        }
    }
    
    public func createQuoteItem(id: String, content: String, author: String) -> QuoteItem {
        let item = QuoteItem(context: DatabaseService.getContext())
        
        item.id = id
        item.content = content
        item.author = author
        item.dateAdded = Date()
        
        return item
    }
    
    public func createQuoteItem(fromQuoteAPI quote: APIQuoteModel) -> QuoteItem {
        return createQuoteItem(id: quote._id!, content: quote.content!, author: quote.author!)
    }
    
    public func createQuoteAPI(fromQuoteItem quote: QuoteItem) -> APIQuoteModel {
        let model = APIQuoteModel(_id: quote.id, content: quote.content, author: quote.author)
        
        return model
    }
}
