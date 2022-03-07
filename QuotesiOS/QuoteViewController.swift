//
//  QuoteViewController.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-07.
//

import UIKit

class QuoteViewController: UIViewController {
    @IBOutlet weak var lbQuote: UILabel!
    @IBOutlet weak var lbAuthor: UILabel!
    
    struct APIQuote: Decodable {
        enum Category: String, Decodable {
            case swift, combine, debugging, xcode
        }
        
        let _id: String
        let tags: [String]
        let content: String
        let author: String
        let authorSlug: String
        let length: UInt
        let dateAdded: String
        let dateModified: String
    }
    
    private var currentQuote: APIQuote?

    public let quoteView: UITextView = {
        let quoteView = UITextView()
        quoteView.contentMode = .scaleAspectFill
        quoteView.backgroundColor = .lightGray
        
        return quoteView
    }()

    private let boldAttr: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.black,
        .font: UIFont.boldSystemFont(ofSize: 24)
    ]

    private let normalAttr: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.darkGray,
        .font: UIFont.systemFont(ofSize: 18)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupQuoteView()
    }
    
    @IBAction func getNewQuote(_ sender: Any) {
        getQuote()
    }
    
    private func setupQuoteView() {
        getQuote()
        
        // Initial setup the Quote
        quoteView.frame = CGRect(x: 0, y: 0, width: view.frame.width-20, height: 0)
        quoteView.translatesAutoresizingMaskIntoConstraints = true
        quoteView.sizeToFit()
        quoteView.isScrollEnabled = false
        
        updateFrame(to: view)
    }
    
    private func getQuote() {
        let urlString = "https://api.quotable.io/random"
        let url = URL(string: urlString)!
        
        guard let json = try? Data(contentsOf: url) else {
            setQuote("Error trying to get Quote", from: "System")
            return
        }
        
        guard let apiQuote = try? JSONDecoder().decode(APIQuote.self, from: json) else {
            setQuote("Error trying to decode Quote", from: "System")
            return
        }
        
        currentQuote = apiQuote
        setQuote(apiQuote.content, from: apiQuote.author)
    }
    
    private func setQuote(_ quote: String, from: String) {
//        let quoteAttr = NSMutableAttributedString(string: "\""+quote+"\"\n", attributes: boldAttr)
//        let fromAttr = NSMutableAttributedString(string: from, attributes: normalAttr)
//
//        quoteAttr.append(fromAttr)
//
//        quoteView.attributedText = quoteAttr
        
        lbQuote.text = quote
        lbAuthor.text = from
    }
    
    /// Update the `quoteView` frame to fit the current text
    private func updateFrame(to view: UIView) {
        quoteView.textAlignment = .center
        quoteView.center = view.center
        quoteView.center.y -= view.frame.height/4
    }
}
