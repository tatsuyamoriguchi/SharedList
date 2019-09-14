//
//  ShareViewController.swift
//  SharedListExtension
//
//  Created by Tatsuya Moriguchi on 9/13/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import Social
import CoreData

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.

        let managedContext = self.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "List", in: managedContext)
        let newBookmark = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        // Get web title
        let contentTextString: String = contentText
        // Save web page title and comments to Core Data
        newBookmark.setValue(contentTextString, forKey: "title")
        
        // Get web URL
        if let item = extensionContext?.inputItems[0] as? NSExtensionItem {
            
            if let itemProviders = item.attachments {
                
                for itemProvider: NSItemProvider in itemProviders {
                    
                    if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                        itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
                            if let shareURL = url as? URL {
                                // Save url to Core Data
                                newBookmark.setValue(shareURL, forKey: "url")
                                print(" ")
                                print("if let shareURL = url as? URL was true")
                                print("shareURL: \(shareURL)")
                            }
                        })
                    }

                }
            
            }
        
        }
        
        
        
        
        
        
        saveContext()
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

    // MARK: = Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSCustomPersistentContainer(name: "SharedList")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: = Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                
            }
        }
    }
    

}
