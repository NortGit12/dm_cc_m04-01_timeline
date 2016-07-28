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
    
    static let recordTypeKey = "Comment"
    
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let postReferenceKey = "postReference"
    
    var recordType = Comment.recordTypeKey
    
    var cloudKitRecord: CKRecord? {
        
        guard let postRecordID = post.cloudKitRecordID else { return nil }
        let postReference = CKReference(recordID: postRecordID, action: .DeleteSelf)
        
        let record = CKRecord(recordType: Comment.recordTypeKey)
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
        
        guard let commentEntity = NSEntityDescription.entityForName(Comment.recordTypeKey, inManagedObjectContext: context) else { return nil }
        
        self.init(entity: commentEntity, insertIntoManagedObjectContext: context)
        
        self.text = text
        self.post = post
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
    }
    
    convenience required init?(record: CKRecord, context: NSManagedObjectContext) {
        
        guard let text = record[Comment.textKey] as? String
            , timestamp = record[Comment.timestampKey] as? NSDate
            , postRecordID = record[Comment.postReferenceKey] as? CKRecordID
            , post = PostController.sharedController.postWithName(postRecordID.recordName)
        else { return nil }
        
        guard let commentEntity = NSEntityDescription.entityForName(Comment.recordTypeKey, inManagedObjectContext: context) else { return nil }
        
        self.init(entity: commentEntity, insertIntoManagedObjectContext: context)
        
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.recordName = record.recordID.recordName
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
    }
    
    // MARK: - Method(s)
    
    func updateWithRecord(record: CKRecord) {
        
        // TODO: Implement this method
        print("\nComment: Implement \"updateWithRecord(_:)\"\n")
    }
    
    // MARK: - SearchableRecord
    func matchesSearchTerm(searchTerm: String) -> Bool {
        
        return text.lowercaseString.containsString(searchTerm)
    }
}
