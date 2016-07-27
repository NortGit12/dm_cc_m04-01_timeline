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
    
    // MARK: - Initialier(s)
    
    init() {
        
//        generateMockData()
    }
    
    // MARK: - Method(s)
    
    func createPost(image: UIImage, caption: String) {
        
        guard let image = UIImageJPEGRepresentation(image, 0.75)
            , post = Post(photoData: image)
        else { return }
        
        _ = Comment(text: caption, post: post)
        
        saveContext()
    }
    
    func deletePost(post: Post) {
        
        moc.deleteObject(post)
        
        saveContext()
    }
    
    func addCommentToPost(text: String, post: Post) {
        
        _ = Comment(text: text, post: post)
        
        saveContext()
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
    
    func generateMockData() {
        
        createPost(UIImage(named: "cheetah")!, caption: "Cool cheetah")
        createPost(UIImage(named: "leopard")!, caption: "Cool leopard")
        createPost(UIImage(named: "tiger")!, caption: "Cool tiger")
    }
}