//
//  Post.swift
//  Timeline
//
//  Created by Jeff Norton on 7/19/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData


class Post: SyncableObject, SearchableRecord {

    // MARK: - Initializer(s)
    
    convenience init?(photo: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let postEntity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else { return nil }
        
        self.init(entity: postEntity, insertIntoManagedObjectContext: context)
        
        self.photoData = photo
        self.recordName = "Post"
        self.timestamp = timestamp
    }
    
    // MARK: - Method(s)
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        
        guard let comments = self.comments else { return false }
        
        var result = false
        for comment in comments {
            
            if comment.matchesSearchTerm(searchTerm) {
                result = true
                break
            }
        }
        
        return result
    }

}
