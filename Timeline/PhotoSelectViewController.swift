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
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        let imageAlertActionSheet = UIAlertController(title: "Select Image", message: "Select an image from the desired source.", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        imageAlertActionSheet.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default) { (_) in
                
                self.imagePickerController.sourceType = .PhotoLibrary
                self.presentViewController(self.imagePickerController, animated: true, completion: nil)
            }
            
            imageAlertActionSheet.addAction(photoLibraryAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            
            let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (_) in
                
                self.imagePickerController.sourceType = .Camera
                self.presentViewController(self.imagePickerController, animated: true, completion: nil)
            }
            
            imageAlertActionSheet.addAction(cameraAction)
        }
        
//        if let popoverController = imageAlertActionSheet.popoverPresentationController {
//            popoverController.sourceView = sender
//            popoverController.sourceRect = sender.bounds
//        }
        
        imageAlertActionSheet.popoverPresentationController?.sourceView = sender
        imageAlertActionSheet.popoverPresentationController?.sourceRect = sender.bounds
        
        presentViewController(imageAlertActionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        imagePickerController.dismissViewControllerAnimated(true, completion: nil)
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        delegate?.photoSelectViewControllerSelectedImage(image)
        selectImageButton.setTitle("", forState: .Normal)
        postImageView.image = image
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
