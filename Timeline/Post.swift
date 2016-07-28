//
//  Post.swift
//  Timeline
//
//  Created by Jeff Norton on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

@objc
class Post: SyncableObject, SearchableRecord, CloudKitManagedObject {
    
    // MARK: - Stored Properties
    
    static let recordTypeKey = "Post"
    
    static let photoKey = "photo"
    static let timestampKey = "timestamp"
    
    var recordType = Post.recordTypeKey
    
    lazy var temporaryPhotoURL: NSURL = {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(self.recordName).URLByAppendingPathExtension("jpg")
        
        self.photoData.writeToURL(fileURL, atomically: true)
        
        return fileURL
    }()
    
    var cloudKitRecord: CKRecord? {
        
        let record = CKRecord(recordType: Post.recordTypeKey)
        record[Post.photoKey] = CKAsset(fileURL: temporaryPhotoURL)
        record[Post.timestampKey]  = timestamp
        
        return record
    }
    
    // MARK: - Initializers

    convenience init(photoData: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let postEntity = NSEntityDescription.entityForName(Post.recordTypeKey, inManagedObjectContext: context) else {
        
            fatalError("Fatal Error: Could not initialize the Post")
        }
        
        self.init(entity: postEntity, insertIntoManagedObjectContext: context)
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
    }
    
    convenience required init?(record: CKRecord, context: NSManagedObjectContext) {
        
        guard let photoData = record[Post.photoKey] as? NSData
            , timestamp = record[Post.timestampKey] as? NSDate
        else { return nil }
        
        guard let postEntity = NSEntityDescription.entityForName(Post.recordTypeKey, inManagedObjectContext: context) else { return nil }
        
        self.init(entity: postEntity, insertIntoManagedObjectContext: context)
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.recordName = record.recordID.recordName
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
    }
    
    // MARK: - Method(s)
    
    func updateWithRecord(record: CKRecord) {
        
        // TODO: Implement this method
        print("\nPost: Implement \"updateWithRecord(_:)\"\n")
    }
    
    // MARK: - SearchableRecord

    func matchesSearchTerm(searchTerm: String) -> Bool {
        
        guard let comments = comments else { return false }
        
        var result = false
        for comment in comments {
            
            guard let comment = comment as? Comment else { break }
            
            if comment.matchesSearchTerm(searchTerm) {
                result = true
                break
            }
        }
        
        return result
    }
}
