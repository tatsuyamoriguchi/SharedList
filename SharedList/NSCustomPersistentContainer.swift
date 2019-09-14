//
//  NSCustomPersistentContainer.swift
//  SharedList
//
//  Created by Tatsuya Moriguchi on 9/13/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class NSCustomPersistentContainer: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.beckos.SharedList")
        storeURL = storeURL?.appendingPathComponent("SharedList.sqlite")
        return storeURL!
    }
}
