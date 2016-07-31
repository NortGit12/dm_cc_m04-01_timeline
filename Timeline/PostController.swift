//
//  PostController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class PostController {
    
    // MARK: - Stored Properties
    
    static let sharedController = PostController()
    let moc = Stack.sharedStack.managedObjectContext
    let cloudKitManager = CloudKitManager()
    var isSyncing: Bool = false
    
    // MARK: - Initialier(s)
    
    init() {
        
//        generateMockData()
        
        subscribeToNewPosts { (success, error) in
            
            if success == true {
                print("Subscribed successfully to all new posts")
            } else {
                print("Error: Problem subscribing to new posts")
            }
        }
        
        performFullSync()
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
                    
                    let moc = Stack.sharedStack.managedObjectContext
                    
                    /*
                     The "...AndWait" makes the subsequent work wait for the performBlock to finish.  By default, the moc.performBlock(...) is asynchronous, so the work in there would be done asynchronously on another thread and the subsequent lines would run immediately.
                    */
                    
                    moc.performBlockAndWait{ post.update(record) }
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
                    
                    let moc = Stack.sharedStack.managedObjectContext
                    moc.performBlock{ comment.update(record) }
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
        
        if name.isEmpty { return nil }
        
        let request = NSFetchRequest(entityName: Post.typeKey)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [name])
        request.predicate = predicate
        
        let result = (try? moc.executeFetchRequest(request) as? [Post]) ?? nil
        
        return result?.first
    }
    
    func commentWithName(name: String) -> Comment? {
        
        if name.isEmpty { return nil }
        
        let request = NSFetchRequest(entityName: Comment.typeKey)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [name])
        request.predicate = predicate
        
        let result = (try? moc.executeFetchRequest(request) as? [Comment]) ?? nil
        
        return result?.first
    }
    
    func syncedManagedObjects(type: String) -> [CloudKitManagedObject] {
        
        let request = NSFetchRequest(entityName: type)
        let predicate = NSPredicate(format: "recordIDData != nil")
        request.predicate = predicate
        
        let syncedRecords = (try? moc.executeFetchRequest(request)) as? [CloudKitManagedObject]
        
        return syncedRecords ?? []
    }
    
    func unsyncedManagedObjects(type: String) -> [CloudKitManagedObject] {
        
        let request = NSFetchRequest(entityName: type)
        let predicate = NSPredicate(format: "recordIDData == nil")
        request.predicate = predicate
        
        let syncedRecords = (try? moc.executeFetchRequest(request)) as? [CloudKitManagedObject]
        
        return syncedRecords ?? []
    }
    
    func fetchNewRecords(type: String, completion: (() -> Void)? = nil) {
        
        var referencesToExclude = [CKReference]()
        
        var predicate: NSPredicate!
        let moc = Stack.sharedStack.managedObjectContext
        moc.performBlockAndWait{
            
            referencesToExclude = self.syncedManagedObjects(Post.typeKey).flatMap{ $0.cloudKitReference }
            
            predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [referencesToExclude])
            
            if referencesToExclude.isEmpty {
                
                predicate = NSPredicate(value: true)
            }
        }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            
            /*
             Again, doing this Core Data work on the same thread as the moc
            */
            
            moc.performBlock {
                
                switch type {
                case Post.typeKey:
                    
                    guard let existingCoreDataPost = self.postWithName(record.recordID.recordName) else {
                        
                        guard let newCoreDataPost = Post(record: record) else {
                            
                            print("Could not create a Post from a Post record")
                            return
                        }
                        
                        return
                    }
                    
                case Comment.typeKey:
                    
                    guard let existingCoreDataComment = self.commentWithName(record.recordID.recordName) else {
                        
                        guard let newCoreDataComment = Comment(record: record) else {
                            
                            print("Could not create a Comment from a Comment record")
                            return
                        }
                        
                        return
                    }
                    
                default: return
                }
                
                
                
                self.saveContext()
            }
            
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
        
        let unsyncedObjectsArray = unsyncedManagedObjects(Post.typeKey) + unsyncedManagedObjects(Comment.typeKey)
        let unsyncedRecordsArray = unsyncedObjectsArray.flatMap{ $0.cloudKitRecord }
        
        cloudKitManager.saveRecords(unsyncedRecordsArray, perRecordCompletion: { (record, error) in
            
            if error != nil {
                print("Error saving unsynced records: \(error)")
            }
            
            guard let record = record else { return }
            
            /*
             This supports multi-threading.  Anything we do with MangedObjectContexts must need to be done on the same thread that it is in.  The code inside this cloudKitManager.saveRecords(...) method will be on a background thread and the MangedObjectContext (moc) is on the main thread, so we need a way to get this.  ALL pieces of things that deal with Core Data need to be in here, working on the main thread where the moc is.  In here the $0.recordName accesses Core Data and so does the .update(...) method.
            */
            let moc = Stack.sharedStack.managedObjectContext
            moc.performBlock {
                
                if let matchingRecord = unsyncedObjectsArray.filter({ $0.recordName == record.recordID.recordName }).first {
                    
                    matchingRecord.update(record)
                }
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
                
                // Doing this here is okay, but not ideal
                completion()
            }
        } else {
            
            isSyncing = true
            
            pushChangestoCloudKit { (_) in
            
                self.fetchNewRecords(Post.typeKey) {
                    
                    self.fetchNewRecords(Comment.typeKey) {
                        
                        self.isSyncing = false
                        
                        if let completion = completion {
                            
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    
    
    // MARK: - Subscriptions
    
    func subscribeToNewPosts(completion: ((success: Bool, error: NSError?) -> Void)?) {
        
        let predicate = NSPredicate(value: true)
        
        cloudKitManager.subscribe(Post.typeKey, predicate: predicate, subscriptionID: "allNewPosts", contentAvailable: true, options: .FiresOnRecordCreation) { (subscription, error) in
            
            if let completion = completion {
                
                let success = subscription != nil
                completion(success: success, error: error)
            }
        }
    }
    
    func addSubscriptionToPostComments(post: Post, alertBody: String?, completion: ((success: Bool, error: NSError?) -> Void)?) {
        
        guard let recordID = post.cloudKitRecordID else {
            
            fatalError("Unable to create CloudKit record reference for subscription.")
        }
        
        let predicate = NSPredicate(format: "post == %@", argumentArray: [recordID])
        
        cloudKitManager.subscribe(Comment.typeKey, predicate: predicate, subscriptionID: post.recordName, contentAvailable: true, alertBody: alertBody, desiredKeys: [Comment.textKey, Comment.postKey], options: .FiresOnRecordCreation) { (subscription, error) in
            
            if let completion = completion {
                
                let success = subscription != nil
                completion(success: success, error: error)
            }
        }
    }
    
    func removeSubscriptionToPostcomments(post: Post, completion: ((success: Bool, error: NSError?) -> Void)?) {
        
        let subscrptionID = post.recordName
        
        cloudKitManager.unsubscribe(subscrptionID) { (subscriptionID, error) in
            
            if let completion = completion {
                
                let success = subscriptionID != nil && error == nil
                completion(success: success, error: error)
            }
        }
    }
    
    func checkSubscriptionToPostComments(post: Post, completion: ((subscribed: Bool) -> Void)?) {
        
        cloudKitManager.fetchSubscription(post.recordName) { (subscription, error) in
            
            if let completion = completion {
                
                let subscribed = subscription != nil
                completion(subscribed: subscribed)
            }
        }
    }
    
    func togglePostCommentSubscription(post: Post, completion: ((success: Bool, isSubscribed: Bool, error: NSError?) -> Void)?) {
        
        cloudKitManager.fetchSubscription(post.recordName) { (subscription, error) in
            
            if subscription != nil {
                
                self.removeSubscriptionToPostcomments(post, completion: { (success, error) in
                    
                    if let completion = completion {
                        
                        completion(success: success, isSubscribed: false, error: error)
                    }
                })
            } else {
                
                self.addSubscriptionToPostComments(post, alertBody: "Somone commented on a post you follow", completion: { (success, error) in
                    
                    if let completion = completion {
                        
                        completion(success: true, isSubscribed: true, error: error)
                    }
                })
            }
        }
    }
    
    func generateMockData() {
        
        createPost(UIImage(named: "cheetah")!, caption: "Cool cheetah")
        createPost(UIImage(named: "leopard")!, caption: "Cool leopard")
        createPost(UIImage(named: "tiger")!, caption: "Cool tiger")
    }
}