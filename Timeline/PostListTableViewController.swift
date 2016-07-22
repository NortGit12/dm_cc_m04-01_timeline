//
//  PostListTableViewController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/18/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    // MARK: - Stored Properties
    
    var fetchedResultsController: NSFetchedResultsController?
    var searchController: UISearchController?
    
    // MARK: - General

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeFetchedResultsController()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setupSearchController()

        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let currentSectionInfo = fetchedResultsController?.sections?[section] else { return 0 }
        
        return currentSectionInfo.numberOfObjects
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            guard let post = fetchedResultsController?.fetchedObjects?[indexPath.row] as? Post else { return }
            
            PostController.sharedController.removePost(post)
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
    
    // MARK: - SearchController Methods
    
    func setupSearchController() {
        
        let searchResultsTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("searchResultsTableViewController")
        
        searchController = UISearchController(searchResultsController: searchResultsTableViewController)
        
        searchController?.searchResultsUpdater = self
        searchController?.hidesNavigationBarDuringPresentation = true
        searchController?.searchBar.placeholder = "Search for a Post..."
        searchController?.definesPresentationContext = true
        tableView.tableHeaderView = searchController?.searchBar
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text?.lowercaseString
            , searchResultsTableViewController = searchController.searchResultsController as? SearchResultsTableViewController
            , posts = fetchedResultsController?.fetchedObjects as? [Post]
            else { return }
        
        searchResultsTableViewController.postListTableViewController = self
        
        searchResultsTableViewController.resultsArray = posts.filter{ $0.matchesSearchTerm(searchText) }
        searchResultsTableViewController.tableView.reloadData()
    }
    
    // MARK: - Methods
    
    func initializeFetchedResultsController() {
        
        let request = NSFetchRequest(entityName: "Post")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: PostController.sharedController.moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("Error fetching posts: \(error)")
        }
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        
        guard let cell = cell as? PostTableViewCell, post = fetchedResultsController?.objectAtIndexPath(indexPath) as? Post else { return }
        
        cell.updateWithPost(post)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Where are we going?
        guard let postDetailTableViewController = segue.destinationViewController as? PostDetailTableViewController else { return }
        
        // How are we getting there?
        if segue.identifier == "fromListToDetailSegue" {
            
            // What do we need to pack?
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let post = fetchedResultsController?.objectAtIndexPath(indexPath) as? Post
                
                // Did I finish packing?
                postDetailTableViewController.post = post
            }
        } else if segue.identifier == "fromSearchToDetailSegue" {
            
            // What do I need to pack?
            guard let cell = sender as? PostTableViewCell
                , searchResultsTableViewController = searchController?.searchResultsController as? SearchResultsTableViewController
                , tableView = searchResultsTableViewController.tableView
                , indexPath = tableView.indexPathForCell(cell)
                , posts = searchResultsTableViewController.resultsArray as? [Post]
            else { return }
            
            let post = posts[indexPath.row]
            
            // Did I finish packing?
            postDetailTableViewController.post = post
            
            searchResultsTableViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }

}