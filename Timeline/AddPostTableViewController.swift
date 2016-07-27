//
//  AddPostTableViewController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    
    // MARK: - Stored Properties
    
    @IBOutlet weak var captionTextField: UITextField!
    
    var postImage: UIImage?
    
    // MARK: - General

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Action(s)
    
    @IBAction func addPostButtonTapped(sender: UIButton) {
        
        guard let image = postImage
            , let text = captionTextField.text where text.characters.count > 0
        else {
        
            let missingElementsAlertController = UIAlertController(title: "Missing Required Elements", message: "A Post needs an image and a caption.  Make sure you have provided both and try again.", preferredStyle: .Alert)
            
            let tryAgainAction = UIAlertAction(title: "Try Again", style: .Default, handler: nil)
            
            missingElementsAlertController.addAction(tryAgainAction)
            
            self.presentViewController(missingElementsAlertController, animated: true, completion: nil)
            
            return
        }
        
        PostController.sharedController.createPost(image, caption: text)
        tableView.reloadData()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // How are we getting there?
        if segue.identifier == "addPostToSelectImageSegue" {
            
            // Where are we going?
            if let photoSelectViewController = segue.destinationViewController as? PhotoSelectViewController {
                
                // What do we need to pack?
                
                
                // Are we finished packing?
                photoSelectViewController.delegate = self
            }
        }
    }

}

extension AddPostTableViewController: PhotoSelectViewControllerDelegate {
    
    func photoSelectViewControllerSelectedImage(image: UIImage) {
        
        self.postImage = image
    }
}
