//
//  SavedViewController.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-07.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import RxDataSources

struct SectionOfQuoteItem {
    var header: String?
    var items: [Item]
}
extension SectionOfQuoteItem: AnimatableSectionModelType {
    typealias Identity = String?
    typealias Item = QuoteItem
    
    var identity: String? { return header }
    
    init(original: SectionOfQuoteItem, items: [Item]) {
        self = original
        self.items = items
    }
}
extension QuoteItem: IdentifiableType {
    public typealias Identity = String?
    
    public var identity: String? { return id }
}

class QuoteListTableViewController: UITableViewController {
    private let quoteListVM = QuoteListViewModel()
    private let disposeBag = DisposeBag()
    
    let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfQuoteItem>(
        animationConfiguration: AnimationConfiguration(insertAnimation: .none, reloadAnimation: .right, deleteAnimation: .fade),
        configureCell: { _, table, idxPath, item in
            let cell = table.dequeueReusableCell(withIdentifier: "quoteCell", for: idxPath) as! QuoteTableViewCell
            
            cell.lbQuote.text = item.content!
            cell.lbAuthor.text = item.author!
            
            // Change background color
            if idxPath.row % 2 == 1 {
                cell.backgroundColor = .systemGray4
            }
            
            return cell
        },
        titleForHeaderInSection: { ds, section -> String? in
            return ds[section].header
        },
        canEditRowAtIndexPath: { _, _ in
            return true
        }
    )
    
    var sections: BehaviorSubject<[SectionOfQuoteItem]> = BehaviorSubject(value: [SectionOfQuoteItem]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Config the rows to have dynamic height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
//        quoteListVM.quoteList.asObservable()
//            .bind(to: tableView.rx.items(cellIdentifier: "quoteCell", cellType: UITableViewCell.self)) { (row, element, cell) in
//                let quoteCell = cell as! QuoteTableViewCell
//                quoteCell.lbQuote.text = element.content!
//                quoteCell.lbAuthor.text = element.author!
//
//                // Change background color
//                if row % 2 == 1 {
//                    quoteCell.backgroundColor = .systemGray4
//                }
//            }.disposed(by: disposeBag)
        
        refreshSections()
        
        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                self?.quoteListVM.removeQuoteFromIndex(indexPath.row)
                try! self?.quoteListVM.refreshList()
                self?.refreshSections()
            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            try quoteListVM.refreshList()
            refreshSections()
        } catch {
            let alert = UIAlertController(title: "Error", message: "Could not retrive data from local database.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func refreshSections() {
        sections.onNext([SectionOfQuoteItem(header: nil, items: quoteListVM.quoteList.value)])
    }
}
