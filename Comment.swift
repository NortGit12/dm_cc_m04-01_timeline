//
//  Comment.swift
//  Timeline
//
//  Created by Jeff Norton on 7/18/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData


class Comment: SyncableObject {

    convenience init?(post: Post, text: String, timestamp: NSDate, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let commentEntity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else { return nil }

        self.init(entity: commentEntity, insertIntoManagedObjectContext: context)

        self.post = post
        self.text = text
        self.timestamp = timestamp
    }
}
