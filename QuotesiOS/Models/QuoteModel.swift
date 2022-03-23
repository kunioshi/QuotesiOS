//
//  QuoteModel.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-21.
//

import UIKit

protocol QuoteModel: Decodable {
    var _id: String? { get }
    var content: String? { get }
    var author: String? { get }
}
