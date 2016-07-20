//
//  AddPostTableViewController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/18/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    
    // MARK: - Stored Properties
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var addPostButton: UIButton!
    
    // MARK: - General

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */
    
    // MARK: - Action(s)
    
    @IBAction func selectImageButtonTapped(sender: UIButton) {
        
        imageView.image = UIImage(named: "default-image")
        
        selectImageButton.titleLabel?.text = ""
    }
    
    @IBAction func addPostButtonTapped(sender: UIButton) {
        
        guard let image = imageView.image, imageData = UIImagePNGRepresentation(image), captionText = captionTextField.text, post = Post(photo: imageData) else {
        
            let missingInfoAlert = UIAlertController(title: "Error - Missing Required Elements", message: "The photo and caption are required.  Make sure they are provided and try again.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            missingInfoAlert.addAction(okAction)
            presentViewController(missingInfoAlert, animated: true, completion: nil)
            
            return
        }
        
        PostController.sharedController.addCommmentToPost(captionText, post: post)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }

}
