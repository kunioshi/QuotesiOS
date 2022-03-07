//
//  SavedViewController.swift
//  QuotesiOS
//
//  Created by Filipe Kunioshi on 2022-03-07.
//

import UIKit
import CoreData

class SavedTableViewController: UITableViewController {
    static var quoteList = [QuoteItem]()
    static let context: NSManagedObjectContext =
        (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            SavedTableViewController.quoteList = try SavedTableViewController.context.fetch(QuoteItem.fetchRequest())
            
            // Wipe DB
//            deleteDBData()
        } catch let error as NSError {
            print("Couldn't fetch quotes! \(error)")
        }
        
        // Config the rows to have dynamic height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    private func deleteDBData() {
        for quote in SavedTableViewController.quoteList {
            SavedTableViewController.context.delete(quote)
        }
        
        do {
            try SavedTableViewController.context.save()
        } catch let error as NSError {
            print("Couldn't delete all DB data! Error: \(error)")
        }
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SavedTableViewController.quoteList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let quoteCell = tableView.dequeueReusableCell(withIdentifier: "quoteCell", for: indexPath) as! QuoteCell

        let quote = SavedTableViewController.quoteList[indexPath.row]
        quoteCell.lbQuote.text = quote.content
        quoteCell.lbAuthor.text = quote.author

        return quoteCell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
