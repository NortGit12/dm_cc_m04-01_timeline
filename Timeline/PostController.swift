//
//  PostController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/18/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostController {
    
    // MARK: - Stored Properties
    
    static let sharedController = PostController()
    
    let moc = Stack.sharedStack.managedObjectContext
    
    let fetchedResultsController: NSFetchedResultsController
    
    weak var delegate: NSFetchedResultsControllerDelegate?
    
    // MARK: - Initializer(s)
    
    init() {
        
        let request = NSFetchRequest(entityName: "Post")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: "timestamp", cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error fetching posts: \(error)")
        }
    }
    
    // MARK: - Method(s)
    
    func createPost(image: UIImage, caption: String) {
        
        guard let imageData = UIImagePNGRepresentation(image) else { return }
        
        let now = NSDate()
        
        guard let post = Post(photo: imageData, timestamp: now) else { return }
        
        _ = Comment(post: post, text: caption, timestamp: now)
        
        saveContext()
    }
    
    func addCommmentToPost(text: String, post: Post) {
        
        _ = Comment(post: post, text: text, timestamp: NSDate())
        
        saveContext()
    }
    
    func saveContext() {
        
        do {
            try moc.save()
        } catch {
            print("Error: Failed to save")
        }
    }
    
}