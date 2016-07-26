//
//  Post.swift
//  Timeline
//
//  Created by Jeff Norton on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData


class Post: SyncableObject, SearchableRecord {
    
    // MARK: - Stored Properties
    
    
    
    // MARK: - Initializers

    convenience init?(photoData: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let postEntity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else { return nil }
        
        self.init(entity: postEntity, insertIntoManagedObjectContext: context)
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
    }
    
    // MARK: - SearchableRecord

    func matchesSearchTerm(searchTerm: String) -> Bool {
        
        var commentsMatch = false
        guard let comments = comments else { return false }
        for comment in comments {
            
            guard let comment = comment as? Comment else { break }
            
            if comment.text.containsString(searchTerm) {
                commentsMatch = true
                return commentsMatch
            }
        }
        
        return commentsMatch
    }
}
