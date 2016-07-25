//
//  PostController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class PostController {
    
    // MARK: - Stored Properties
    
    static let sharedController = PostController()
    let moc = Stack.sharedStack.managedObjectContext
    
    // MARK: - Initialier(s)
    
    
    
    // MARK: - Method(s)
    
    func createPost(image: UIImage, caption: String) {
        
        guard let image = UIImageJPEGRepresentation(image, 0.75) else { return }
        
        _ = Post(photoData: image)
        
        saveContext()
    }
    
    func addCommentToPost(text: String, post: Post) {
        
        _ = Comment(text: text, post: post)
        
        saveContext()
    }
    
    func saveContext() {
        
        do {
            try moc.save()
        } catch {
            let errorMessge = "Error: Saving the context failed."
            print("errorMessge")
            NSLog(errorMessge)
        }
    }
}