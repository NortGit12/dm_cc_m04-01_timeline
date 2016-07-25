//
//  CustomTableViewCell.swift
//  Timeline
//
//  Created by Jeff Norton on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    // MARK: - Stored Properties
    
    @IBOutlet weak var postImageView: UIImageView?
    
    // MARK: - General
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Method(s)
    
    func updateWithPost(post: Post) {
        
        postImageView?.image = UIImage(data: post.photoData)
    }

}
