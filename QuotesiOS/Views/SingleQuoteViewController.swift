//
//  QuoteViewController.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-07.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa

class SingleQuoteViewController: UIViewController {
    @IBOutlet weak var lbQuote: UILabel!
    @IBOutlet weak var lbAuthor: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var quoteView: UIView!
    @IBOutlet weak var transitionQuoteView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var quoteVM: QuoteViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize ViewModel
        quoteVM = QuoteViewModel(newQuoteCallback: newQuoteDidSet)
        
        // Rx
        quoteVM.currentQuote.asObservable()
            .subscribe(onNext: { [weak self] element in
                self?.SwitchSpinner(toHidden: true)
                self?.updateBtnSave()
                UIView.transition(with: (self?.transitionQuoteView)!,
                              duration: 0.25,
                               options: .transitionCurlDown,
                            animations: {
                                self?.lbQuote.text = element.content
                                self?.lbAuthor.text = element.author
                         }, completion: nil)
            })
            .disposed(by: disposeBag)
        
        btnSave.rx.tap.bind { [weak self] in
            self?.tappedBtnSave()
        }.disposed(by: disposeBag)
        
        btnRefresh.rx.tap.bind { [weak self] in
            self?.quoteVM.getNewQuote()
        }.disposed(by: disposeBag)
        
        // Format UI elements
        quoteView.layer.cornerRadius = 8
        quoteView.layer.masksToBounds = true
        
        SwitchSpinner(toHidden: false)
        
        quoteVM.getNewQuote()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Covers the case that the user deleted the `currentQuote` from the `quoteList`
        updateBtnSave()
    }
    
    private func newQuoteDidSet() {
        let (content, author) = quoteVM.getCurrentContent()
        
        if (activityIndicator.isHidden) {
            setQuoteLabels(quote: content, from: author, animated: true)
        } else {
            setQuoteLabels(quote: content, from: author)
            SwitchSpinner(toHidden: true)
        }
        
        updateBtnSave()
    }
    
    private func tappedBtnSave() {
        if quoteVM.isCurrentQuoteSaved() {
            quoteVM.removeCurrentQuote()
        } else {
            quoteVM.saveCurrentQuote()
        }
        
        updateBtnSave()
    }
    
    /// Verify if the `currentQuote` is already saved. Changes the Save Button image to correspond to it.
    private func updateBtnSave() {
        if quoteVM.isCurrentQuoteSaved() {
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
    
    private func setQuoteLabels(quote: String, from: String, animated: Bool = true) {
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
