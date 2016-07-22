//
//  CloudKitManagedObject.swift
//  Timeline
//
//  Created by Jeff Norton on 7/22/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

protocol CloudKitManagedObject {
    
    var timestamp: NSDate { get set } // date and time the object was created
    var recordIDData: NSData? { get set } // persisted CKRecordID
    var recordName: String { get set } // unique name for the object
    var recordType: String { get set } // a consistent type string, 'Post' for Post, 'Comment' for Comment
    
    var cloudKitRecord: CKRecord? { get set } // a generated record representation of the `NSManagedObject` that can be saved to CloudKit (similar to `dictionaryValue` when working with REST APIs)
    
    init?(record: CKRecord, context: NSManagedObjectContext) // to initialize a new `NSManagedObject` from a `CKRecord` from CloudKit (similar to `init?(json: [String: AnyObject])` when working with REST APIs)
    
    mutating func updateWithRecord(record: CKRecord) // update the Core Data object with the CKRecord data received from CloudKit
    
}

extension CloudKitManagedObject {
    
    /*
     When a record is synced to CloudKit, CloudKit returns a CKRecord object. You will pass that CKRecord object into the update(record: CKRecord) function, which will save the record.recordID as NSData to the recordIDData variable. So if that recordIDData variable has data, then the object has been synced. If not, it hasn't.
     */
    var isSynced: Bool {
        
        return recordIDData != nil ? true : false
    }
    
    /*
     This is simply a helper function that returns our persisted NSData? version of the CKRecordID as an actual CKRecordID.  Use NSKeyedUnarchiver to decode the NSData
     */
    var cloudKitRecordID: CKRecordID? {
        
        guard let recordIDData = recordIDData else { return nil }
        
        let ckRecordID = NSKeyedUnarchiver.unarchiveObjectWithData(recordIDData) as? CKRecordID
        
        return ckRecordID
    }
    
    // a computed property that returns a CKReference to the object in CloudKit
    var cloudKitReference: CKReference? {
        
        guard let cloudKitRecordID = cloudKitRecordID else { return nil }
        
        return CKReference(recordID: cloudKitRecordID, action: .None)
    }
    
    var nameForManagedObject: String {
        
        return NSUUID().UUIDString
    }
    
    // MARK: - Method(s)
    
    // called after saving the object, saved the record.recordID to the recordIDData
    mutating func update(record: CKRecord) {
        
        let nsDataRecord = NSKeyedArchiver.archivedDataWithRootObject(record)
        
        self.recordIDData = nsDataRecord
        
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Error: Could not update the CloudKitManagedObject record")
        }
    }
    
    func updateWithRecord(record: CKRecord) {
        
        
    }
    
}