//
//  ImageTableViewCell.swift
//  nyanChat
//
//  Created by George Tang on 1/10/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var picImageView: UIImageView!
    @IBOutlet weak var aspectTallConstraint: NSLayoutConstraint!
    @IBOutlet weak var aspectWideConstraint: NSLayoutConstraint!
    
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
