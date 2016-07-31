//
//  PostListTableViewController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: - Stored Properties
    
    var fetchedResultsController: NSFetchedResultsController?
    var searchController: UISearchController?
    weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - General

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        initializeFetchedResultsController()

        setUpSearchController()
        
        self.refreshControl?.addTarget(self, action: #selector(PostListTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        tableView.backgroundView = activityIndicatorView
        
        self.activityIndicatorView = activityIndicatorView
        
        requestFullSync()
        
        // Hides the search bar
        
        if tableView.numberOfRowsInSection(0) > 0 {
            
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
        }
    }
    
    // MARK: - Method(s)
    
    func requestFullSync(completion: (() -> Void)? = nil) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        PostController.sharedController.performFullSync {

            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if let completion = completion {
                
                completion()
            }
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        initializeFetchedResultsController()
        
        requestFullSync {
            refreshControl.endRefreshing()
        }
    }
    
    func initializeFetchedResultsController() {
        
        let request = NSFetchRequest(entityName: "Post")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: PostController.sharedController.moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
        refreshFetchedResults()
    }
    
    func refreshFetchedResults() {
        
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
    
    func setUpSearchController() {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let resultsController = storyboard.instantiateViewControllerWithIdentifier("resultsTableViewController")
        
        guard let resultsTableViewController = resultsController as? SearchResultsTableViewController else { return }
        resultsTableViewController.sourceTableViewController = self
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController?.searchResultsUpdater = self
        searchController?.hidesNavigationBarDuringPresentation = true
        searchController?.searchBar.placeholder = "Search comments..."
        searchController?.searchBar.delegate = self
        searchController?.definesPresentationContext = true
        tableView.tableHeaderView = searchController?.searchBar
        
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        refreshFetchedResults()
        
        guard let searchTermLowercase = searchController.searchBar.text?.lowercaseString
            , searchResultsController = searchController.searchResultsController as? SearchResultsTableViewController
            , posts = fetchedResultsController?.fetchedObjects as? [Post]
        else { return }
        
        let resultsArray = posts.filter{ $0.matchesSearchTerm(searchTermLowercase) }
        
        searchResultsController.resultsArray = resultsArray
        searchResultsController.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        guard let cell = tableView.dequeueReusableCellWithIdentifier("listCell", forIndexPath: indexPath) as? CustomTableViewCell else { return UITableViewCell() }
        
        if let post = fetchedResultsController?.fetchedObjects?[indexPath.row] as? Post {
            
            cell.updateWithPost(post)
        }

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
        case .Move:
            break
        case .Update:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Move:
            guard let indexPath = indexPath, newIndexPath = newIndexPath else { return }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Update:
            guard let indexPath = indexPath, tableViewCell = self.tableView.cellForRowAtIndexPath(indexPath) else { return }
            configureCell(tableViewCell, indexPath: indexPath)
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
            if let postDetailTableviewController = segue.destinationViewController as? PostDetailTableViewController {
                
                // What do I need to pack?
                if let index = tableView.indexPathForSelectedRow?.row {
                
                    let post = fetchedResultsController?.fetchedObjects?[index] as? Post
                
                    // Am I finished packing?
                    postDetailTableviewController.post = post
                }
            }
        } else if segue.identifier == "searchResultToDetailSegue" {
            
            // Where am I going?
            if let postDetailViewController = segue.destinationViewController as? PostDetailTableViewController {
                
                // What do I need to pack?
                guard let cell = sender as? CustomTableViewCell
                    , searchResultsController = searchController?.searchResultsController as? SearchResultsTableViewController
                    , searchResultsTableView = searchResultsController.tableView
                    , searchResultsIndexPath = searchResultsTableView.indexPathForCell(cell)
                    , post = searchResultsController.resultsArray?[searchResultsIndexPath.row] as? Post
                else { return }
                
                // Am I finished packing
                postDetailViewController.post = post
                
                searchController?.searchBar.text = ""
                searchController?.searchBar.resignFirstResponder()
                
                searchResultsController.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    

}
