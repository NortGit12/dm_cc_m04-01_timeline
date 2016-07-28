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
    var isSyncing: Bool = false
    
    // MARK: - Initialier(s)
    
    init() {
        
        generateMockData()
        
//        performFullSync()
    }
    
    // MARK: - Method(s)
    
    func createPost(image: UIImage, caption: String, completion: (() -> Void)? = nil) {
        
        guard let image = UIImageJPEGRepresentation(image, 0.75) else { return }
        
        let post = Post(photoData: image)
        
        addCommentToPost(caption, post: post)
        
        saveContext()
        
        if let completion = completion {
            
            completion()
        }
        
        if let postCloudKitRecord = post.cloudKitRecord {
            
            cloudKitManager.saveRecord(postCloudKitRecord) { (record, error) in
                
                if error != nil {
                    print("Error saving the Post and/or it's Comment to CloudKit: \(error)")
                }
                
                if let record = record {
                    
                    post.update(record)
                }
            }
        }
    }
    
    func deletePost(post: Post) {
        
        moc.deleteObject(post)
        
        saveContext()
    }
    
    func addCommentToPost(text: String, post: Post, completion: ((success: Bool) -> Void)? = nil) {
        
        let comment = Comment(text: text, post: post)
        
        saveContext()
        
        if let completion = completion {
            
            completion(success: true)
        }
        
        if let commentCloudKitRecord = comment.cloudKitRecord {
            
            cloudKitManager.saveRecord(commentCloudKitRecord) { (record, error) in
                
                if error != nil {
                    print("Error saving comment to post: \(error)")
                }
                
                if let record = record {
                    
                    comment.update(record)
                }
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
    
    func fetchNewRecords(type: String, completion: (() -> Void)? = nil) {
        
        let referencesToExclude = syncedRecords(Post.typeKey).flatMap{ $0.cloudKitReference }
        
        var predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [referencesToExclude])
        
        if referencesToExclude.isEmpty {
            
            predicate = NSPredicate(value: true)
        }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            
            switch type {
            case Post.typeKey:
                let _ = Post(record: record)
            case Comment.typeKey:
                let _ = Comment(record: record)
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
        
        let unsyncedObjectsArray = unsyncedRecords(Post.typeKey) + unsyncedRecords(Comment.typeKey)
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
        
        if isSyncing == true {
            
            if let completion = completion {
                
                completion()
            }
        } else {
            
            isSyncing = true
            
//            pushChangestoCloudKit{ (_, _) in
            
                self.fetchNewRecords(Post.typeKey) {
                    
                    self.fetchNewRecords(Comment.typeKey) {
                        
                        self.isSyncing = false
                        
                        if let completion = completion {
                            
                            completion()
                        }
                    }
                }
//            }
        }
    }
    
    func generateMockData() {
        
//        createPost(UIImage(named: "cheetah")!, caption: "Cool cheetah")
//        createPost(UIImage(named: "leopard")!, caption: "Cool leopard")
        createPost(UIImage(named: "tiger")!, caption: "Cool tiger")
    }
}