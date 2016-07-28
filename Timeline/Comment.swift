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

@objc
class Comment: SyncableObject, SearchableRecord, CloudKitManagedObject {
    
    // MARK: - Stored Properties
    
    static let typeKey = "Comment"
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let postKey = "post"
    
    var recordType = Comment.typeKey
    
    var cloudKitRecord: CKRecord? {
        
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record[Comment.textKey] = text
        record[Comment.timestampKey] = timestamp
        
        guard let postRecord = post.cloudKitRecord else {
            fatalError("Comment does not have a Post relationship")
        }
        
        record[Comment.postKey] = CKReference(record: postRecord, action: .DeleteSelf)
        
        return record
    }

    var descriptionString: String {
        
        return "\ttext = \(text)\ttimestamp = \(timestamp)\trecordName = \(recordName)"
    }
    
    // MARK: - Initializers
    
    convenience init(text: String, post: Post, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let commentEntity = NSEntityDescription.entityForName(Comment.typeKey, inManagedObjectContext: context) else {
            
            fatalError("Error: Core Data failed to create entity from entity description.")
        }
        
        self.init(entity: commentEntity, insertIntoManagedObjectContext: context)
        
        self.text = text
        self.post = post
        self.timestamp = timestamp
        self.recordName = self.nameForManagedObject()
    }
    
    convenience required init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let text = record[Comment.textKey] as? String
            , timestamp = record.creationDate
            , postReference = record[Comment.postKey] as? CKReference
        else { return nil }
        
        guard let commentEntity = NSEntityDescription.entityForName(Comment.typeKey, inManagedObjectContext: context) else {
            
            fatalError("Error: Core Data failed to create entity from entity description.")
        }
        
        self.init(entity: commentEntity, insertIntoManagedObjectContext: context)
        
        self.text = text
        self.timestamp = timestamp
        
        if let post = PostController.sharedController.postWithName(postReference.recordID.recordName) {
            self.post = post
        }
        
        self.recordName = record.recordID.recordName
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
    }
    
    // MARK: - SearchableRecord
    func matchesSearchTerm(searchTerm: String) -> Bool {
        
        return text.lowercaseString.containsString(searchTerm)
    }
}
