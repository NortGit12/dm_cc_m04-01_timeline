//
//  PostTableViewCell.swift
//  Timeline
//
//  Created by Jeff Norton on 7/18/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    // MARK: - Stored Properties
    
    @IBOutlet weak var postImageView: UIImageView!
    
    // MARK: - General
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Method(s)
    
    func updateWithPost(post: Post) {
        
        postImageView.image = UIImage(data: post.photoData)
    }

}
