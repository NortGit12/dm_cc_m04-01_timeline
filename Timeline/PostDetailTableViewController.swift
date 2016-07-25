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
    
    var post: Post?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        initializeFetchedResultsController()

        if let post = post {
            
            updateWithPost(post)
            tableView.reloadData()
        }
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
        }
        
        commentAlertController.addAction(cancelAction)
        commentAlertController.addAction(okAction)
        
        tableView.reloadData()
        
        presentViewController(commentAlertController, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(sender: UIButton) {
        
        
    }
    
    @IBAction func followButtonTapped(sender: UIButton) {
        
        
    }
    

}
