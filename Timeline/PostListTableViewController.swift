//
//  PostListTableViewController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Stored Properties
    
    var fetchedResultsController: NSFetchedResultsController?
    
    // MARK: - General

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeFetchedResultsController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Method(s)
    
    func initializeFetchedResultsController() {
        
        let request = NSFetchRequest(entityName: "Post")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: PostController.sharedController.moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            let errorMessage = "Error fetching posts.  \(error)"
            print("\(errorMessage)")
            NSLog(errorMessage)
        }
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        
        guard let cell = cell as? CustomTableViewCell, post = fetchedResultsController?.objectAtIndexPath(indexPath) as? Post else { return }
        
        cell.updateWithPost(post)
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        guard let cell = tableView.dequeueReusableCellWithIdentifier("listCell", forIndexPath: indexPath) as? CustomTableViewCell
            , post = fetchedResultsController?.fetchedObjects?[indexPath.row] as? Post
        else { return UITableViewCell() }

        cell.updateWithPost(post)

        return cell
    }


    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            guard let post = fetchedResultsController?.fetchedObjects?[indexPath.row] as? Post else { return }
            
            PostController.sharedController.deletePost(post)
        }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // How am I getting there?
        if segue.identifier == "listToDetailSegue" {
            
            // Where am I going?
            if let detailTableviewController = segue.destinationViewController as? PostDetailTableViewController {
                
                // What do I need to pack?
                if let index = tableView.indexPathForSelectedRow?.row {
                
                    let post = fetchedResultsController?.fetchedObjects?[index] as? Post
                
                    // Am I finished packing?
                    detailTableviewController.post = post
                }
            }
        }
    }
    

}
