//
//  SearchResultsTableViewController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    
    // MARK: - Stored Properties
    
    @IBOutlet weak var postImageView: UIImageView!
    
    var resultsArray: [SearchableRecord]?

    // MARK: - General
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return resultsArray?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        guard let cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath) as? CustomTableViewCell
            , post = resultsArray?[indexPath.row] as? Post
        else { return UITableViewCell() }
        
        cell.postImageView.image = UIImage(data: post.photoData)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        
        presentingViewController?.performSegueWithIdentifier("searchResultsToDetailSegue", sender: cell)
    }

}
