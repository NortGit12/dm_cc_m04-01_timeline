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
    
    static let typeKey = "Post"
    static let photoDataKey = "photoData"
    static let timestampKey = "timestamp"
    
    var recordType = Post.typeKey
    
    lazy var temporaryPhotoURL: NSURL = {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(self.recordName).URLByAppendingPathExtension("jpg")
        
        self.photoData.writeToURL(fileURL, atomically: true)
        
        return fileURL
    }()
    
    var cloudKitRecord: CKRecord? {
        
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record[Post.photoDataKey] = CKAsset(fileURL: temporaryPhotoURL)
        record[Post.timestampKey]  = timestamp
        
        return record
    }
    
    // MARK: - Initializers

    convenience init(photoData: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let postEntity = NSEntityDescription.entityForName(Post.typeKey, inManagedObjectContext: context) else {
        
            fatalError("Fatal Error: Could not initialize the Post")
        }
        
        self.init(entity: postEntity, insertIntoManagedObjectContext: context)
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.recordName = self.nameForManagedObject()
    }
    
    convenience required init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let recordAssetData = record[Post.photoDataKey] as? CKAsset
            , photoData = NSData(contentsOfURL: recordAssetData.fileURL)
            , timestamp = record.creationDate
        else { return nil }
        
        guard let postEntity = NSEntityDescription.entityForName(Post.typeKey, inManagedObjectContext: context) else {
            
            fatalError("Error: Core Data failed to create entity from entity description.")
        }
        
        self.init(entity: postEntity, insertIntoManagedObjectContext: context)
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.recordName = record.recordID.recordName
        
        /*
         Core Data doesn't store CloudKit types, such as CKRecords and CKRecordIDs, so we use this to convert a CKRecordID into NSData
         
         Conforming to the NSCoding protocol means that a class knows how to turn itself into and out from raw binary data (NSData)
        */
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
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
