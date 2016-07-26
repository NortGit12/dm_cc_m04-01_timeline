//
//  Comment.swift
//  Timeline
//
//  Created by Jeff Norton on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData


class Comment: SyncableObject {

    // MARK: - Stored Properties
    
    
    
    // MARK: - Initializers
    
    convenience init?(text: String, post: Post, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let commentEntity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else { return nil }
        
        self.init(entity: commentEntity, insertIntoManagedObjectContext: context)
        
        self.text = text
        self.post = post
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
    }
}
