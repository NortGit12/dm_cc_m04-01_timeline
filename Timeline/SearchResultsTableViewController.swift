//
//  SearchResultsTableViewController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/18/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class SearchResultsTableViewController: UITableViewController {

    // MARK: - Stored Properties
    
    weak var postListTableViewController: PostListTableViewController?
    
    var resultsArray: [SearchableRecord] = []
    
    // MARK: - General
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return resultsArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath) as? PostTableViewCell, post = resultsArray[indexPath.row] as? Post else { return UITableViewCell() }

        cell.updateWithPost(post)

        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        print("cell = \(cell)")
        
//        guard let presentingViewController = presentingViewController else { return }
//        
//        print("presentingViewController = \(presentingViewController)")
//        
//        presentingViewController.performSegueWithIdentifier("fromSearchToDetailSegue", sender: cell)
        
        postListTableViewController?.performSegueWithIdentifier("fromSearchToDetailSegue", sender: cell)
    }
}
