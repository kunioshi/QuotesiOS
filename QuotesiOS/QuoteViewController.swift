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
    @IBOutlet weak var btnSave: UIButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Force the DB load
        QuoteController.getQuotes()
        
        getAPIQuote()
        checkCurrentQuote()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Covers the case that the user deleted the `currentQuote` from the `quoteList`
        checkCurrentQuote()
    }
    
    @IBAction func getNewQuote(_ sender: Any) {
        getAPIQuote()
        checkCurrentQuote()
    }
    
    @IBAction func saveQuote(_ sender: UIButton) {
        if let curQuote = currentQuote {
            if QuoteController.isQuoteSaved(id: curQuote._id) {
                if QuoteController.deleteQuote(id: curQuote._id) {
                    showAlert(title: "Removed", msg: "\(curQuote.author)'s quote was removed from your list. 😢")
                    
                    checkCurrentQuote()
                    return
                } else {
                    showAlert(title: "Error", msg: "Couldn't remove \(curQuote.author)'s quote from your list.\nPlease, try again.")
                    return
                }
            }
            
            let newQuote = QuoteController.createQuote(
                id: curQuote._id,
                content: curQuote.content,
                author: curQuote.author
            )
            if QuoteController.saveQuote(newQuote) {
                showAlert(title: "Saved", msg: "\(curQuote.author)'s quote was added to your favorite/saved list.")
                
                checkCurrentQuote()
                return
            } else {
                showAlert(title: "Error", msg: "The app couldn't save the current quote.\nPlease, try again.")
                return
            }
        } else {
            showAlert(title: "Error", msg: "The app is confuse... Is there a quote? Try to save another quote.")
        }
    }
    
    /// Verify if the `currentQuote` is already saved. Changes the Save Button image to correspond to it.
    private func checkCurrentQuote() {
        if QuoteController.isQuoteSaved(id: currentQuote!._id) {
            btnSave.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            btnSave.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
    
    private func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getAPIQuote() {
        let urlString = "https://api.quotable.io/random"
        let url = URL(string: urlString)!
        
        guard let json = try? Data(contentsOf: url) else {
            showAlert(title: "Error", msg: "The app wasn't able to get Quote from server!\nPlease, close and open the app again.")
            return
        }
        
        guard let apiQuote = try? JSONDecoder().decode(APIQuote.self, from: json) else {
            showAlert(title: "Error", msg: "The app wasn't able to decode the server's message!\nPlease, close and open the app again.")
            return
        }
        
        currentQuote = apiQuote
        setQuoteLabels(apiQuote.content, from: apiQuote.author)
    }
    
    private func setQuoteLabels(_ quote: String, from: String) {
        lbQuote.text = "“"+quote+"”"
        lbAuthor.text = from
    }
}
