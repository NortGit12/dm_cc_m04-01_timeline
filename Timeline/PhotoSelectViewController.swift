//
//  PhotoSelectorViewController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/26/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

protocol PhotoSelectViewControllerDelegate: class {
    
    func photoSelectViewControllerSelectedImage(image: UIImage)
}

class PhotoSelectViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - Stored Properties
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    var imagePickerController = UIImagePickerController()
    
    weak var delegate: PhotoSelectViewControllerDelegate?
    
    // MARK: - General

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePickerController.delegate = self
    }
    
    // MARK: - Action(s)
    
    @IBAction func selectImageButtonTapped(sender: UIButton) {
        
        selectImageButton.titleLabel?.text = ""
        
        imagePickerController.allowsEditing = true
        
        let imageAlertActionSheet = UIAlertController(title: "Select Image", message: "Select an image from the desired source.", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default) { (_) in
            
            self.imagePickerController.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePickerController, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (_) in
            
            self.imagePickerController.sourceType = .Camera
            self.presentViewController(self.imagePickerController, animated: true, completion: nil)
        }
        
        imageAlertActionSheet.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            
            imageAlertActionSheet.addAction(photoLibraryAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imageAlertActionSheet.addAction(cameraAction)
        }
        
        presentViewController(imageAlertActionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        delegate?.photoSelectViewControllerSelectedImage(image)
        postImageView.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
