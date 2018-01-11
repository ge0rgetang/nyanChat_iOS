//
//  TextTableViewCell.swift
//  nyanChat
//
//  Created by George Tang on 1/10/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
