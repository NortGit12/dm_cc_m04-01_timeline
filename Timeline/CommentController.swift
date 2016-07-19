//
//  CommentController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/19/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData

class CommentController {
    
    // MARK: - Stored Properties
    
    static let sharedController = PostController()
    
    let moc = Stack.sharedStack.managedObjectContext
    
    var commentFetchedResultsController: NSFetchedResultsController?
    
    weak var delegate: NSFetchedResultsControllerDelegate?
    
    // MARK: - Method(s)
    
    func getCommentFetchedResultsControllerForPost(post: Post) {
        
        let commentFetchRequest = NSFetchRequest(entityName: "Comment")
        commentFetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        commentFetchRequest.predicate = NSPredicate(format: "post == %@", post)
        
        commentFetchedResultsController = NSFetchedResultsController(fetchRequest: commentFetchRequest, managedObjectContext: moc, sectionNameKeyPath: "timestamp", cacheName: nil)
        
        do {
            try commentFetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error fetching comments: \(error)")
        }
    }
    
}