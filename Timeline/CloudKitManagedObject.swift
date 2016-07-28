//
//  CloudKitManagedObject.swift
//  Timeline
//
//  Created by Jeff Norton on 7/27/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

@objc
protocol CloudKitManagedObject {
    
    // MARK: - Stored Properties
    
    var timestamp: NSDate { get set }
    var recordIDData: NSData? { get set }
    var recordName: String { get set }
    var recordType: String { get }
    var cloudKitRecord: CKRecord? { get }
    
    // MARK: - Initializer(s)
    
    init?(record: CKRecord, context: NSManagedObjectContext)
    
    // MARK: - Method(s)
    
    func updateWithRecord(record: CKRecord)
    
}

extension CloudKitManagedObject {
    
    // MARK: - Stored Properties
    
    var isSynced: Bool { return recordIDData != nil }
    
    var nameForManagedObject: String { return NSUUID().UUIDString }
    
    var cloudKitRecordID: CKRecordID? {
        
        guard let recordIDData = recordIDData else { return nil }
        
        return NSKeyedUnarchiver.unarchiveObjectWithData(recordIDData) as? CKRecordID
    }
    
    var cloudKitReference: CKReference? {
        
        guard let cloudKitRecordID = cloudKitRecordID else { return nil }
        
        return CKReference(recordID: cloudKitRecordID, action: .DeleteSelf)
    }
    
    // MARK: - Method(s)
    
//    func updateWithRecord(record: CKRecord) {
//        
//        // TODO: Implement this method
//        print("\nImplement \"updateWithRecord(_:)\"\n")
//    }
    
    func update(record: CKRecord) {
        
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Unable to save Managed Object Context: \(error)")
        }
    }
    
}