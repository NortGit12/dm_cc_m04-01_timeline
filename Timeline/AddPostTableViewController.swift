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
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var captionTextField: UITextField!
    
    // MARK: - General

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Action(s)
    
    @IBAction func selectImageButtonTapped(sender: UIButton) {
        
        guard let image = UIImage(named: "default-image") else {
            print("Error loading image")
            return
        }
        
        postImageView.image = image
        tableView.reloadData()
    }
    
    @IBAction func addPostButtonTapped(sender: UIButton) {
        
        selectImageButton.titleLabel?.text = ""
        
        guard let image = postImageView.image
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

}
