//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/18/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostDetailTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Stored Properties
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var commentBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var shareBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var followPostBarButtonItem: UIBarButtonItem!
    
    var post: Post?
    
    // MARK: - General

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeFetchedResultsController()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        if let post = post {
            
            updateWithPost(post)
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let numberOfRows = post?.comments?.count else { return 0 }
        
        return numberOfRows
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("postDetailCell", forIndexPath: indexPath)
        
        configureCell(cell, indexPath: indexPath)

        return cell
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move: break
        case .Update: break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Update:
            configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: - Methods
    
    func initializeFetchedResultsController() {
        
        guard let post = post else { return }
        
        let request = NSFetchRequest(entityName: "Comment")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        request.predicate = NSPredicate(format: "post == %@", post)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: PostController.sharedController.moc, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error fetching comments: \(error)")
        }
    }
    
    func updateWithPost(post: Post) {
        
        let imageData = post.photoData
        photoImageView.image = UIImage(data: imageData)
        tableView.reloadData()
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {

        guard let comments = post?.comments else { return }
        
        let comment = comments[indexPath.row]
        
        cell.textLabel?.text = comment.text
    }
    
    // MARK: - Action(s)
    
    @IBAction func commentButtonTapped(sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "New Comment", message: "", preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (commentTextField) in
            
            commentTextField.placeholder = "New comment..."
            commentTextField.becomeFirstResponder()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            
            guard let post = self.post, newPostText = alertController.textFields?[0].text where newPostText.characters.count > 0 else { return }
            
            PostController.sharedController.addCommmentToPost(newPostText, post: post)
            self.tableView.reloadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(sender: UIBarButtonItem) {
        
        if let post = post {
            
            guard let image = UIImage(data: post.photoData)
                , captionText = post.comments?[0].text
            else { return }
            
            let shareActivityViewController = UIActivityViewController(activityItems: [image, captionText], applicationActivities: nil)
            
            presentViewController(shareActivityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func followButtonTapped(sender: UIBarButtonItem) {
        
        
    }

}
