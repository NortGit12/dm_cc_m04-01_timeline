//
//  PostController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostController {
    
    // MARK: - Stored Properties
    
    static let sharedController = PostController()
    let moc = Stack.sharedStack.managedObjectContext
    let cloudKitManager = CloudKitManager()
    
    // MARK: - Initialier(s)
    
    init() {
        
//        generateMockData()
        
        performFullSync()
    }
    
    // MARK: - Method(s)
    
    func createPost(image: UIImage, caption: String) {
        
        guard let image = UIImageJPEGRepresentation(image, 0.75)
//            , post = Post(photoData: image)
        else { return }
        
        let post = Post(photoData: image)
        
        _ = Comment(text: caption, post: post)
        
        saveContext()
        
        guard let postCloudKitRecord = post.cloudKitRecord else { return }
        
        cloudKitManager.saveRecord(postCloudKitRecord) { (record, error) in
            
            if error != nil {
                print("Error saving the Post to CloudKit: \(error)")
            }
            
            if let record = record {
                
                post.update(record)
            }
        }
    }
    
    func deletePost(post: Post) {
        
        moc.deleteObject(post)
        
        saveContext()
    }
    
    func addCommentToPost(text: String, post: Post) {
        
        let comment = Comment(text: text, post: post)
        
        saveContext()
        
        guard let commentCloudKitRecord = comment?.cloudKitRecord else { return }
        
        cloudKitManager.saveRecord(commentCloudKitRecord) { (record, error) in
            
            if error != nil {
                print("Error saving comment to post: \(error)")
            }
            
            if let record = record {
                
                comment?.update(record)
            }
        }
    }
    
    func deleteComment(comment: Comment) {
        
        moc.deleteObject(comment)
        
        saveContext()
    }
    
    func saveContext() {
        
        do {
            try moc.save()
        } catch {
            let errorMessge = "Error: Saving the context failed."
            print("\(errorMessge)")
            NSLog(errorMessge)
        }
    }
    
    func postWithName(name: String) -> Post? {
        
        let request = NSFetchRequest(entityName: "Post")
        let predicate = NSPredicate(format: "post.recordName == %@", argumentArray: [name])
        request.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: No post found with the name \"\(name)\".  \(error)")
        }
        
        return fetchedResultsController.fetchedObjects?.first as? Post ?? nil
    }
    
    func syncedRecords(type: String) -> [CloudKitManagedObject] {
        
        let request = NSFetchRequest(entityName: type)
        let predicate = NSPredicate(format: "recordIDData != nil")
        request.predicate = predicate
        
        let syncedRecords = (try? moc.executeFetchRequest(request)) as? [CloudKitManagedObject]
        
        return syncedRecords ?? []
    }
    
    func unsyncedRecords(type: String) -> [CloudKitManagedObject] {
        
        let request = NSFetchRequest(entityName: type)
        let predicate = NSPredicate(format: "recordIDData == nil")
        request.predicate = predicate
        
        let syncedRecords = (try? moc.executeFetchRequest(request)) as? [CloudKitManagedObject]
        
        return syncedRecords ?? []
    }
    
    func pushChangesToCloudKit(completion: ((success: Bool, error: NSError?) -> Void)?) {
        
        let unsyncedObjectsArray = unsyncedRecords(Post.recordTypeKey) + unsyncedRecords(Comment.recordTypeKey)
        let unsyncedRecordsArray = unsyncedObjectsArray.flatMap{ $0.cloudKitRecord }
        
        cloudKitManager.saveRecords(unsyncedRecordsArray, perRecordCompletion: { (record, error) in
            
            if error != nil {
                print("Error saving unsynced records: \(error)")
            }
            
            guard let record = record else { return }
            
            if let matchingRecord = unsyncedObjectsArray.filter({ $0.recordName == record.recordID.recordName }).first {
                
                matchingRecord.update(record)
            }
            
        }) { (records, error) in
            
            if let completion = completion {
                
                let success = records != nil
                completion(success: success, error: error)
            }
        }
    }
    
    func fetchNewRecords(type: String, completion: (() -> Void)? = nil) {
        
        let referencesToExclude = syncedRecords(Post.recordTypeKey).flatMap{ $0.cloudKitReference }
        
        var predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [referencesToExclude])
        
        if referencesToExclude.isEmpty {
            
            predicate = NSPredicate(value: true)
        }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            
            switch type {
            case Post.recordTypeKey: _ = Post(record: record)
            case Comment.recordTypeKey: _ = Comment(record: record)
            default: return
            }
            
            self.saveContext()
            
        }) { (records, error) in
            
            if error != nil {
                print("Error fetching records: \(error)")
            }
            
            if let completion = completion {
                
                completion()
            }
        }
        
    }
    
    func pushChangestoCloudKit(completion: ((success: Bool, error: NSError?) -> Void)? = nil) {
        
        let unsyncedObjectsArray = unsyncedRecords(Post.recordTypeKey) + unsyncedRecords(Comment.recordTypeKey)
        let unsyncedRecordsArray = unsyncedObjectsArray.flatMap{ $0.cloudKitRecord }
        
        cloudKitManager.saveRecords(unsyncedRecordsArray, perRecordCompletion: { (record, error) in
            
            if error != nil {
                print("Error saving unsynced records: \(error)")
            }
            
            guard let record = record else { return }
            
            if let matchingRecord = unsyncedObjectsArray.filter({ $0.recordName == record.recordID.recordName }).first {
                
                matchingRecord.update(record)
            }
            
        }) { (records, error) in
            
            if let completion = completion {
                
                let success = records != nil
                completion(success: success, error: error)
            }
        }
    }
    
    func performFullSync(completion: (() -> Void)? = nil) {
        
        pushChangestoCloudKit{ (success, error) in

            if success == true {
                
                self.fetchNewRecords(Post.recordTypeKey) {
                    
                    self.fetchNewRecords(Comment.recordTypeKey)
                }
            }
        }
    }
    
    func generateMockData() {
        
        createPost(UIImage(named: "cheetah")!, caption: "Cool cheetah")
        createPost(UIImage(named: "leopard")!, caption: "Cool leopard")
        createPost(UIImage(named: "tiger")!, caption: "Cool tiger")
    }
}