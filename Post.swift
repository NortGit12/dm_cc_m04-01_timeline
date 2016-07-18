//
//  Post.swift
//  Timeline
//
//  Created by Jeff Norton on 7/18/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData


class Post: SyncableObject {

    convenience init?(photo: NSData, timestamp: NSDate, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let postEntity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else { return nil }
        
        self.init(entity: postEntity, insertIntoManagedObjectContext: context)
        
        self.photoData = photo
        self.timestamp = timestamp
    }
}
