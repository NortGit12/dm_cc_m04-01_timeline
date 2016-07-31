//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostDetailTableViewController: UITableViewController {
    
    // MARK: - Stored Properties
    
    var fetchedResultsController: NSFetchedResultsController?
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var followPostBarButtonItem: UIBarButtonItem!
    
    var post: Post?
    
    var comments: [Comment]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50

        if let post = post {
            
            updateWithPost(post)
            tableView.reloadData()
        }
        
        initializeFetchedResultsController()
    }
    
    // MARK: - Method(s)
    
    func initializeFetchedResultsController() {
        
        guard let post = post else { return }
        
        let request = NSFetchRequest(entityName: "Comment")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        request.predicate = NSPredicate(format: "post == %@", post)
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Stack.sharedStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            let errorMessage = "Error: Couldn't fetch post comments.  \(error)."
            print("\(errorMessage)")
            NSLog("\(errorMessage)")
        }
    }
    
    func updateWithPost(post: Post) {
        
        postImageView.image = UIImage(data: post.photoData)
        
        PostController.sharedController.checkSubscriptionToPostComments(post) { (subscribed) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.followPostBarButtonItem.title = subscribed ? "Unfollow Post" : "Follow Post"
            })
        }
    }
    
    func refreshDataAndView() {
        
        do {
            try self.fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("Error fetching comments: \(error)")
        }
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath)

        // Option 1
//        guard let post = post
//            , comments = post.comments
//            , comment = comments[indexPath.row] as? Comment
        // Option 2
        guard let comment = fetchedResultsController?.fetchedObjects?[indexPath.row]
        else { return UITableViewCell() }
        
        cell.textLabel?.text = comment.text

        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        refreshDataAndView()
        
        guard let comment = fetchedResultsController?.fetchedObjects?[indexPath.row] as? Comment else { return }
        
        PostController.sharedController.deleteComment(comment)
        
        refreshDataAndView()
    }
    
    // MARK: - Action(s)
    
    @IBAction func commentButtonTapped(sender: UIButton) {
        
        let commentAlertController = UIAlertController(title: "Add New Comment", message: "Enter a new comment for this post", preferredStyle: .Alert)
        
        commentAlertController.addTextFieldWithConfigurationHandler { (captionTextField) in
            
            captionTextField.placeholder = "Caption..."
            captionTextField.becomeFirstResponder()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            
            guard let post = self.post, text = commentAlertController.textFields?[0].text where text.characters.count > 0 else { return }
            
            PostController.sharedController.addCommentToPost(text, post: post)
            
            self.refreshDataAndView()
        }
        
        commentAlertController.addAction(cancelAction)
        commentAlertController.addAction(okAction)
        
        presentViewController(commentAlertController, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(sender: UIButton) {
        
        guard let imageData = post?.photoData
            , image = UIImage(data: imageData)
            , firstComment = post?.comments?.firstObject as? Comment
        else { return }
        
        let captionText = firstComment.text
        
        let activityShareController = UIActivityViewController(activityItems: [image, captionText], applicationActivities: nil)
        
        presentViewController(activityShareController, animated: true, completion: nil)
    }
    
    @IBAction func followButtonTapped(sender: UIButton) {
        
        guard let post = post else { return }
        
        PostController.sharedController.togglePostCommentSubscription(post) { (success, isSubscribed, error) in
            
            self.updateWithPost(post)
        }
    }

}
