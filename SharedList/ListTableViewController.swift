//
//  ListTableViewController.swift
//  SharedList
//
//  Created by Tatsuya Moriguchi on 9/13/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData


class ListTableViewController: UITableViewController {

    @IBAction func addButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a bookmark", message: "Add a bookmark title.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let saveAction = UIAlertAction(title: "Add", style: .default, handler: { action in
            let textField = alert.textFields![0] as UITextField
            if textField.text != "" {
                self.addBookmark(name: textField.text!)
            } else {
                print("Error: Alert textField.text was nil.")
            }



        })
        
        alert.addTextField()
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func addBookmark(name: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "List", in: managedContext)
        let bookmark = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        bookmark.setValue(name, forKey: "title")
        
        do {
            try managedContext.save()
            bookmarks.append(bookmark)
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureFetchedResultsController()
        self.tableView.reloadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    // MARK: CoreData
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var bookmarks: [NSManagedObject] = []
    
    // MARK: -Configure FetchResultsController
    private func configureFetchedResultsController() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        //let sortDescriptorURL = NSSortDescriptor(key: "url", ascending: false)
        let sortDescriptorTitle = NSSortDescriptor(key: "title", ascending: true)
        
        //fetchRequest.sortDescriptors = [sortDescriptorURL, sortDescriptorTitle]
        fetchRequest.sortDescriptors = [sortDescriptorTitle]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = fetchedResultsController {
            return frc.sections!.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultscontroller")
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        if let object = self.fetchedResultsController?.object(at: indexPath) as? List {
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = object.title
            //cell.detailTextLabel?.text = "TEST" //object.url?.absoluteString
            
        } else {
            fatalError("Attempt configure cell without a managed object")
        }
    
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("didSelectRowAt was tapped.")
        let bookmark = self.fetchedResultsController?.object(at: indexPath) as? List
        let urlStored = bookmark?.url

        if urlStored != nil { UIApplication.shared.open(urlStored!, options: [:], completionHandler: nil)}
        else { print("Error: No urlStored Found")}
        
    }

    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
            
            let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
            let wordToDelete = fetchedResultsController?.object(at: indexPath)
            managedContext?.delete(wordToDelete as! NSManagedObject)
            
            do {
                try managedContext?.save()
                
            } catch {
                print("Saving Error: \(error)")
                // Error occured while deleting objects
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

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

extension ListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
        print("controllerWillChangeContent was detected")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .delete:
            print("delete was detected.")
            self.tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .update:
            if(indexPath != nil) {
                self.tableView.cellForRow(at: indexPath! as IndexPath)
                
            }
        case .move:
            self.tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
            self.tableView.insertRows(at: [indexPath! as IndexPath], with: .fade)
        @unknown default:
            print("Fatal Error at switch")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        print("tableView data update was ended at controllerDidChangeContent().")
        
    }
}
