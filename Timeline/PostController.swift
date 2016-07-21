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
    
    // MARK: - Initializer(s)
    
    init() {
        
//        createMockData()
    }
    
    // MARK: - Method(s)
    
    func createPost(image: UIImage, caption: String) {
        
        guard let imageData = UIImagePNGRepresentation(image) else { return }
        
        guard let post = Post(photo: imageData) else { return }
        
        addCommmentToPost(caption, post: post)
        
        saveContext()
    }
    
    func removePost(post: Post) {
        
        moc.deleteObject(post)
        
        saveContext()
    }
    
    func addCommmentToPost(text: String, post: Post) {
        
        _ = Comment(post: post, text: text)
        
        saveContext()
    }
    
    func saveContext() {
        
        do {
            try moc.save()
        } catch let error {
            print("Error: Failed to save (error: \(error)")
        }
    }
    
    func createMockData() {
        
        var mockPosts: [Post] = []
        
        guard let cheetahImage = UIImage(named: "cheetah")
            , let leopardImage = UIImage(named: "leopard")
            , let tigerImage = UIImage(named: "tiger")
            , let cheetahImageData = UIImagePNGRepresentation(cheetahImage)
            , let leopardImageData = UIImagePNGRepresentation(leopardImage)
            , let tigetImageData = UIImagePNGRepresentation(tigerImage)
            , let cheetahPost = Post(photo: cheetahImageData)
            , let leopardPost = Post(photo: leopardImageData)
            , let tigerPost = Post(photo: tigetImageData)
            else { return }
        
        addCommmentToPost("Cool Cheetah", post: cheetahPost)
        addCommmentToPost("Cool Leopard", post: leopardPost)
        addCommmentToPost("Cool Tiger", post: tigerPost)
        
        mockPosts.append(cheetahPost)
        mockPosts.append(leopardPost)
        mockPosts.append(tigerPost)
        
        saveContext()
    }
    
}