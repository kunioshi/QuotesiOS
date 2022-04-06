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
            } else {
                cell.backgroundColor = .systemGray3
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
        
        quoteListVM.quoteList.asObservable()
            .bind(onNext: { [weak self] _ in
                self?.refreshSections()
            }).disposed(by: disposeBag)
        
        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .bind(onNext: { [weak self] indexPath in
                self?.quoteListVM.removeQuoteFromIndex(indexPath.row)
            }).disposed(by: disposeBag)
    }
    
    private func refreshSections() {
        sections.onNext([SectionOfQuoteItem(header: nil, items: quoteListVM.quoteList.value)])
    }
}
