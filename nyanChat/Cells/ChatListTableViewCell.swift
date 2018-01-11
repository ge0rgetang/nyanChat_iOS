//
//  ChatListTableViewCell.swift
//  nyanChat
//
//  Created by George Tang on 1/10/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
