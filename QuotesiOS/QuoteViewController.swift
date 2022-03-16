//
//  QuoteViewController.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-07.
//

import UIKit
import Alamofire

class QuoteViewController: UIViewController {
    @IBOutlet weak var lbQuote: UILabel!
    @IBOutlet weak var lbAuthor: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var quoteView: UIView!
    @IBOutlet weak var transitionQuoteView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        
        // Format UI elements
        quoteView.layer.cornerRadius = 8
        quoteView.layer.masksToBounds = true
        
        SwitchSpinner(toHidden: false)
        
        getAPIQuote(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Covers the case that the user deleted the `currentQuote` from the `quoteList`
        checkCurrentQuote()
    }
    
    @IBAction func getNewQuote(_ sender: Any) {
        getAPIQuote()
    }
    
    @IBAction func saveQuote(_ sender: UIButton) {
        if let curQuote = currentQuote {
            if QuoteModelView.isQuoteSaved(id: curQuote._id) {
                if QuoteModelView.deleteQuote(id: curQuote._id) {
                    showAlert(title: "Removed", msg: "\(curQuote.author)'s quote was removed from your list. 😢")
                    
                    checkCurrentQuote()
                    return
                } else {
                    showAlert(title: "Error", msg: "Couldn't remove \(curQuote.author)'s quote from your list.\nPlease, try again.")
                    return
                }
            }
            
            let newQuote = QuoteModelView.createQuote(
                id: curQuote._id,
                content: curQuote.content,
                author: curQuote.author
            )
            if QuoteModelView.saveQuote(newQuote) {
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
        if let curQuote = currentQuote, QuoteModelView.isQuoteSaved(id: curQuote._id) {
            btnSave.setBackgroundImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            btnSave.setBackgroundImage(UIImage(systemName: "star"), for: .normal)
        }
    }
    
    private func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Uses Swift vanilla URL to request the Quote from the API
//    private func getAPIQuote() {
//        let urlString = "https://api.quotable.io/random"
//        let url = URL(string: urlString)!
//
//        guard let json = try? Data(contentsOf: url) else {
//            showAlert(title: "Error", msg: "The app wasn't able to get Quote from server!\nPlease, close and open the app again.")
//            return
//        }
//
//        guard let apiQuote = try? JSONDecoder().decode(APIQuote.self, from: json) else {
//            showAlert(title: "Error", msg: "The app wasn't able to decode the server's message!\nPlease, close and open the app again.")
//            return
//        }
//
//        currentQuote = apiQuote
//        setQuoteLabels(apiQuote.content, from: apiQuote.author)
//    }
    
    /// Uses Alamofire to request the Quote from the API
    private func getAPIQuote(animated: Bool = true) {
        AF.request("https://api.quotable.io/random").responseDecodable(of: APIQuote.self) { (response) in
            guard let apiQuote = response.value else {
                self.showAlert(title: "Error", msg: "The app wasn't able to get Quote from server!\nPlease, close and open the app again.")
                return
            }
             
            self.currentQuote = apiQuote
            self.setQuoteLabels(apiQuote.content, from: apiQuote.author, animated: animated)
            self.SwitchSpinner(toHidden: true)
            self.checkCurrentQuote()
        }
    }
    
    private func setQuoteLabels(_ quote: String, from: String, animated: Bool = true) {
        if animated {
            UIView.transition(with: transitionQuoteView,
                          duration: 0.25,
                           options: .transitionCurlDown,
                        animations: { [weak self] in
                            self!.lbQuote.text = "“"+quote+"”"
                            self!.lbAuthor.text = from
                     }, completion: nil)
        } else {
            lbQuote.text = "“"+quote+"”"
            lbAuthor.text = from
        }
    }
    
    private func SwitchSpinner(toHidden hide: Bool) {
        activityIndicator.isHidden = hide
        
        if hide {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
}
