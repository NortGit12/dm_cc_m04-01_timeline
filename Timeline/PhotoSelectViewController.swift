//
//  PhotoSelectViewController.swift
//  Timeline
//
//  Created by Jeff Norton on 7/21/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

protocol PhotoSelectViewControllerDelegate: class {
    
    func photoSelectViewControllerSelected(image: UIImage)
}


class PhotoSelectViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // MARK: - Stored Properties
    
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: PhotoSelectViewControllerDelegate?
    
    let imagePickerController = UIImagePickerController()
    
    // MARK: - General
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        imagePickerController.delegate = self
    }
    
    // MARK: - Action(s)
    
    @IBAction func selectImageButtonTapped(sender: UIButton) {
        
        imagePickerController.allowsEditing = false
        
        let imageAlertActionSheet = UIAlertController(title: "Image Source", message: "Select the desired source for images", preferredStyle: .ActionSheet)
        
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
        
        selectImageButton.titleLabel?.text = ""
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        delegate?.photoSelectViewControllerSelected(image)
        imageView.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}