//
//  Comment.swift
//  Timeline
//
//  Created by Jeff Norton on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import CloudKit


class Comment: SyncableObject, SearchableRecord, CloudKitManagedObject {
    
    // MARK: - Stored Properties
    
    static var recordType: String { return "Comment" }
    
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let postReferenceKey = "postReference"
    
    var postController = PostController()
    
    var cloudKitRecord: CKRecord? {
        
        guard let postRecordID = post.cloudKitRecordID else { return nil }
        let postReference = CKReference(recordID: postRecordID, action: .DeleteSelf)
        
        let record = CKRecord(recordType: Comment.recordType)
        record[Comment.textKey] = text
        record[Comment.timestampKey] = timestamp
        record[Comment.postReferenceKey] = postReference
        
        return record
    }

    var descriptionString: String {
        
        return "\ttext = \(text)\ttimestamp = \(timestamp)\trecordName = \(recordName)"
    }
    
    // MARK: - Initializers
    
    convenience init?(text: String, post: Post, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let commentEntity = NSEntityDescription.entityForName(Comment.recordType, inManagedObjectContext: context) else { return nil }
        
        self.init(entity: commentEntity, insertIntoManagedObjectContext: context)
        
        self.text = text
        self.post = post
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
    }
    
    convenience init?(record: CKRecord, context: NSManagedObjectContext) {
        
        guard let text = record[Comment.textKey] as? String
            , timestamp = record[Comment.timestampKey] as? NSDate
            , postRecordID = record[Comment.postReferenceKey] as? CKRecordID
            , post = postController.postWithName(postRecordID.recordName)
        else { return nil }
        
        guard let commentEntity = NSEntityDescription.entityForName(Comment.recordType, inManagedObjectContext: context) else { return nil }
        
        self.init(entity: commentEntity, insertIntoManagedObjectContext: context)
        
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.recordName = record.recordID.recordName
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
    }
    
    // MARK: - SearchableRecord
    func matchesSearchTerm(searchTerm: String) -> Bool {
        
        return text.lowercaseString.containsString(searchTerm)
    }
}
