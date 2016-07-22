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
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var addPostButton: UIButton!
    
    weak var imageViewController: UIViewController?
    
    var image: UIImage?
    
    // MARK: - Action(s)
    
    @IBAction func addPostButtonTapped(sender: UIButton) {
        
        guard let image = image, captionText = captionTextField.text else {
        
            let missingInfoAlert = UIAlertController(title: "Error - Missing Required Elements", message: "The photo and caption are required.  Make sure they are both provided and try again.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            missingInfoAlert.addAction(okAction)
            presentViewController(missingInfoAlert, animated: true, completion: nil)
            
            return
        }
        
        PostController.sharedController.createPost(image, caption: captionText)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "embedSegueToImageContainer" {
            
            let embedViewController = segue.destinationViewController as? PhotoSelectViewController
            embedViewController?.delegate = self
        }
    }

}

extension AddPostTableViewController: PhotoSelectViewControllerDelegate {
    
    func photoSelectViewControllerSelected(image: UIImage) {
        
        self.image = image
    }
}